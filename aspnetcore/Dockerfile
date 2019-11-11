FROM mcr.microsoft.com/dotnet/core/sdk:2.1-nanoserver-1809

WORKDIR /root/
ADD ./app/ ./app/
WORKDIR /root/app

RUN dotnet restore
RUN dotnet build

EXPOSE 5000/tcp 

ENTRYPOINT ["dotnet", "run", "--server.urls", "http://0.0.0.0:5000"]

