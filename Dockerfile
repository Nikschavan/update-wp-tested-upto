FROM debian:stable-slim

LABEL "com.github.actions.name"="WordPress Plugin Readme Update"
LABEL "com.github.actions.description"="Deploy readme and asset updates to the WordPress Plugin Repository"
LABEL "com.github.actions.icon"="upload-cloud"
LABEL "com.github.actions.color"="blue"

LABEL maintainer="Nikhil Chavan <email@nikhilchavan.com>"
LABEL version="1.0.0"
LABEL repository="https://github.com/Nikschavan/update-wp-tested-upto"

RUN apt-get update \
	&& apt-get install -y curl jq git hub \
	&& apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/* \
	&& git config --global user.email "update-tested-upto-wp@bsf.io" \
	&& git config --global user.name "Update Tested upto Bot on GitHub"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
