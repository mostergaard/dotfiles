@echo off
cd C:\Data\Postgresql
docker run -d -p 5432:5432 -v postgres-data:/var/lib/postgresql/data --name postgres1 postgres:alpine 