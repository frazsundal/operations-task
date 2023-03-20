# The Dockerfile defines the image's environment
# Import Python runtime and set up working directory
FROM python:3.8
WORKDIR /rates


# Install any necessary dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update  && apt-get install -y python3-pip --upgrade pip


# create a application user
RUN useradd -ms /bin/bash worker
USER worker
WORKDIR /home/worker

#install dependancies using application user
COPY --chown=worker:worker requirements.txt requirements.txt
RUN pip install --user -r requirements.txt

ENV PATH="/home/worker/.local/bin:${PATH}"
RUN  pip install --user gunicorn
COPY --chown=worker:worker . .


# Open port 3000 for serving the webpage


EXPOSE 3000

CMD ["gunicorn" , "--bind", "0.0.0.0:3000" , "wsgi"]



