#!/bin/bash

docker compose down

docker rmi vicio/app

docker compose up -d