FROM python:3.10.8-alpine3.16 as python-alpine

ENV P1="pip3 download --cache-dir . --only-binary=:all"
ENV P2="pip3 install --find-links=. --cache-dir . --disable-pip-version-check"

RUN apk add --no-cache build-base linux-headers # && apk del build-base linux-headers && rm -rf /var/cache/apk/*

COPY requirements.txt .
RUN $P1 pip setuptools wheel -r requirements.txt && $P2 pip setuptools wheel && \
  $P2 $(ls *.gz | tr '\n' ' ') && $P2 $(ls *.whl | tr '\n' ' ') && \
  find /usr/local/lib/python3.10 -name '__pycache__' -type d -print0 | xargs -0 /bin/rm -rf '{}' && \
  find /usr/local/lib/python3.10 -iname '*.pyc' -delete

FROM python:3.10.8-alpine3.16

COPY --from=python-alpine /usr/local/lib/python3.10 /usr/local/lib/python3.10
COPY --from=python-alpine /usr/local/bin /usr/local/bin

COPY . /app
COPY supervisord.conf /etc/supervisord.conf

WORKDIR /app

CMD [ "supervisord", "-c", "/etc/supervisord.conf" ]
