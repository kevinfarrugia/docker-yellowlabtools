FROM    node:18-alpine

ENV VERSION=develop

WORKDIR /usr/src/ylt

RUN apk upgrade --update && apk --no-cache add git gcc make g++ zlib-dev libjpeg-turbo-dev nasm automake autoconf libtool \
  && git clone https://github.com/kevinfarrugia/YellowLabTools-server.git -b ${VERSION} . \
  &&  NODE_ENV=development && npm install jpegoptim-bin --unsafe-perm=true --allow-root --legacy-peer-deps --omit=dev \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/main" >> /etc/apk/repositories \
  && apk upgrade -U -a \
  && apk add \
    libjpeg-turbo-dev \
    chromium \
    ca-certificates \
    freetype \
    freetype-dev \
    harfbuzz \
    nss \
    ttf-freefont \
  && which chromium-browser && chromium-browser --version &&  chown -R nobody:nogroup . \
  && rm -rf test doc

# Create the results directory and assign nobody:nogroup as the owner
RUN mkdir -p /usr/src/ylt/results && chown -R nobody:nogroup /usr/src/ylt/results

# Add the volume for results
VOLUME /usr/src/ylt/results

# Tell Puppeteer to skip installing Chrome. We'll be using the installed binary
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Run everything after as non-privileged user.
USER nobody

# Set up the Chromium environment
ENV XDG_CONFIG_HOME /tmp/.chromium
ENV XDG_CACHE_HOME /tmp/.chromium

# Tell phantomas where Chromium binary is and that we're in docker
ENV PHANTOMAS_CHROMIUM_EXECUTABLE /usr/bin/chromium-browser
ENV DOCKERIZED yes

# ENV DEBUG *

EXPOSE  8383

CMD     ["node", "bin/server.js"]
