docker build -t spark .
docker tag spark miguel96/spark:latest
docker push miguel96/spark:latest
docker run miguel96/spark:latest
