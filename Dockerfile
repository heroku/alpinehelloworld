# Grab the latest alpine image
FROM alpine:latest

# Install python and pip
RUN apk add --update python py-pip 
ADD ./webapp/requirements.txt /tmp/requirements.txt

# Install dependencies
RUN pip install -qr /tmp/requirements.txt

# Add our code
ADD ./webapp /opt/webapp/
WORKDIR /opt/webapp

# Expose is not supported
EXPOSE 5000 		

# Run the app			
CMD ["python", "app.py"]

