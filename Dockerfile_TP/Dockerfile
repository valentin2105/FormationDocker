FROM debian

RUN mkdir app/ && \
    apt-get update && \
    apt-get install -y python3 \
    python3-pip && \
    rm -rf /var/lib/apt/lists/* 


RUN pip3 install flask

ADD hello.py /app/

EXPOSE 80

CMD ["python3", "/app/hello.py"]
