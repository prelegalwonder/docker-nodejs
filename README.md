#### Building the image:

```
1. clone this repo 
2. cd dockerfiles/haroopad
3. docker build --build-arg NODE_VERSION=0.10 -t haroopad:v1 -f Dockerfile .
4. if it completes successfully, you should see an image for it in: docker images
```

#### Running the image:
Something like:<br> 

```
docker run -d \
            --name haroopad \
            -e NODE_ENV=<env> \
            -e MY_BRANCH=<branch> \
            -p 8443:8443 \
            --link <mysql-container>:my-<env> \ 
            haroopad:v1
```
<br>
Check that it didn't exit with an error `docker ps -a`<br>
Check logs `docker logs -f haroopad`<br>
