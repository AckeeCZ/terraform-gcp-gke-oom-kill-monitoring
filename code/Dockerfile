FROM google/cloud-sdk:408.0.1

RUN python3 -m pip install requests google-cloud-monitoring
COPY check_oom_killed_pods.py /opt/check_oom_killed_pods.py

CMD ["python3", "/opt/check_oom_killed_pods.py"]
