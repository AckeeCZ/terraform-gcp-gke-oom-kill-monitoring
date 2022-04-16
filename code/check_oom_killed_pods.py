import os

import requests
import json
from google.cloud import monitoring_v3
import time

client = monitoring_v3.MetricServiceClient()
PROJECT_ID = os.environ.get('PROJECT_ID', "flash-news-development")
LOCATION = os.environ.get('LOCATION', "europe-west3-c")
CLUSTER_NAME = os.environ.get('CLUSTER_NAME', "flash-news-development-50479")

APISERVER = "https://kubernetes.default.svc"
SERVICEACCOUNT = "/var/run/secrets/kubernetes.io/serviceaccount"
NAMESPACE = os.environ.get('NAMESPACE', "development")

project_name = f"projects/{PROJECT_ID}"

while True:
    with open(f"{SERVICEACCOUNT}/token") as f:
        TOKEN = f.read()
    with open(f"{SERVICEACCOUNT}/ca.crt") as f:
        CACERT = f.read()
    try:
        response = requests.get(
            f"{APISERVER}/api/v1/namespaces/{NAMESPACE}/pods", verify=f"{SERVICEACCOUNT}/ca.crt",
            headers={'Authorization': f"Bearer {TOKEN}"}
        )
        response.raise_for_status()
    except requests.HTTPError as e:
        print(json.dumps({'http_error': f'Http error {e.response.status_code}'}))
    except requests.exceptions.RequestException as e:
        print(json.dumps({'http_error': f'Connection refused'}))
    except Exception as e:
        print(json.dumps({'http_error': f'Uknown connection'}))
    else:
        response = response.json()
        for i in response['items']:
            submit_pod = False
            container_statuses = i['status'].get('containerStatuses', [])
            if not len(container_statuses):
                continue
            container_statuses = container_statuses[0]
            last_state = container_statuses.get('lastState')
            if last_state is {}:
                continue
            for k, v in last_state.items():
                if k == "terminated":
                    if v['reason'] == "OOMKilled":
                        submit_pod = True
            if submit_pod:
                series = monitoring_v3.TimeSeries()
                series.metric.type = "custom.googleapis.com/gke_oom_kills"
                series.resource.type = "k8s_pod"
                series.resource.labels["project_id"] = PROJECT_ID
                series.resource.labels["location"] = LOCATION
                series.resource.labels["cluster_name"] = CLUSTER_NAME
                series.resource.labels["namespace_name"] = NAMESPACE
                series.resource.labels["pod_name"] = i['metadata']['name']
                now = time.time()
                seconds = int(now)
                nanos = int((now - seconds) * 10 ** 9)
                interval = monitoring_v3.TimeInterval(
                    {"end_time": {"seconds": seconds, "nanos": nanos}}
                )
                point = monitoring_v3.Point({"interval": interval, "value": {"bool_value": True}})
                series.points = [point]
                client.create_time_series(request={"name": project_name, "time_series": [series]})
    time.sleep(60)
