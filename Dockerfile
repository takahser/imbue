FROM paritytech/ci-linux:staging AS builder
LABEL maintainer="imbue-dev"
ARG PROFILE=release
ARG IMBUE_GIT_REPO="https://github.com/ImbueNetwork/imbue.git"
ARG GIT_BRANCH="main"
ARG GIT_CLONE_DEPTH="--depth 1"

# WORKDIR /builds
#Build imbue-collator
RUN git clone --recursive ${IMBUE_GIT_REPO} ${GIT_CLONE_DEPTH}
WORKDIR /builds/imbue
RUN cargo build --${PROFILE}
RUN cp target/${PROFILE}/imbue-collator /

FROM parity/polkadot:v0.9.13 AS polkadot
FROM parity/subkey:latest AS subkey
# to copy polkadot binaries only; no other directives required

FROM node:16-slim
ARG APT_PACKAGES
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y\
        gnupg2 ca-certificates\
        ${APT_PACKAGES}


RUN yarn global add polkadot-launch

COPY --from=builder /imbue-collator /
COPY --from=polkadot /usr/bin/polkadot /
COPY --from=subkey /usr/local/bin/subkey /

EXPOSE 30330-30345 9933-9960 8080 3001
