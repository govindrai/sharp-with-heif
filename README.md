# lambda-media-handler

Work in Progress
-- currently attempting to build the correct libvips binary that will process heic files with sharp


# one-liner to build and run 

```bash
docker build --progress plain -t sharp:test . && docker rm -f sharp-container && docker run -d --name sharp-container sharp:test && docker exec -it sharp-container npm test
```
