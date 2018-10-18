FROM solr:7.5.0

WORKDIR /opt/solr/server/solr

USER root
COPY . .
RUN chown -R solr:solr .
USER solr