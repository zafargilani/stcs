Building the beef image:

    docker build -t beef .

Running beef container:

    docker run -d --name dbeef beef

Getting container ip:

    docker inspect --format '{{ .NetworkSettings.IPAddress }}' dbeef

Accessing container ui panel:

    http://<container-ip>:3000/ui/authentication