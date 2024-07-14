FROM lightdash/lightdash:0.1170.0 as builder_lightdash

FROM python:3.10-slim-bookworm

ARG MELTANO_VERSION="3.4"

# Meltano project directory - this is where you should mount your Meltano project
ARG WORKDIR="/usr/app"

ENV PIP_NO_CACHE_DIR=1

RUN mkdir "${WORKDIR}" && \
    apt-get update && \
    apt-get install -y build-essential freetds-bin freetds-dev git libkrb5-dev libssl-dev tdsodbc unixodbc unixodbc-dev && \
    rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

WORKDIR "${WORKDIR}"

# Create a virtual environment, and activate it
RUN python -m venv /venv
ENV PATH="/venv/bin:${PATH}"

# Installing the application the same way our users do when using PyPI
RUN pip install --upgrade pip wheel && \
    pip install "meltano[azure,gcs,mssql,postgres,psycopg2,s3,uv]==${MELTANO_VERSION}"

COPY --from=builder_lightdash /usr/local/dbt1.4 /usr/local/dbt1.4
COPY --from=builder_lightdash /usr/local/dbt1.5 /usr/local/dbt1.5
COPY --from=builder_lightdash /usr/local/dbt1.6 /usr/local/dbt1.6
COPY --from=builder_lightdash /usr/local/dbt1.7 /usr/local/dbt1.7
COPY --from=builder_lightdash /usr/local/dbt1.8 /usr/local/dbt1.8
COPY --from=builder_lightdash /usr/app /usr/app
COPY --from=builder_lightdash /usr/app/lightdash.yml /usr/app/lightdash.yml
ENV LIGHTDASH_CONFIG_FILE /usr/app/lightdash.yml

ENTRYPOINT ["meltano"]