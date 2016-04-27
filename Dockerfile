FROM alpine:latest
RUN apk add --update python py-pip 
ADD ./webapp/requirements.txt /tmp/requirements.txt
RUN pip install -qr /tmp/requirements.txt
ADD ./webapp /opt/webapp/
WORKDIR /opt/webapp
EXPOSE 5000 							#NOT SUPPORTED
CMD ["python", "app.py"]

