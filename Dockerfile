### image to contribute, verify, finish ceremonies
FROM node AS zk-ceremony

WORKDIR /app

RUN npm config set update-notifier false && \
    npm install -g snarkjs

RUN apt update \
    && apt install --no-install-recommends -y curl \
    && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
    && apt install --no-install-recommends -y git-lfs \
    && git lfs install \
    && apt install --no-install-recommends -y jq \
    && apt install -y gh \
    && apt autoremove -y \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ~/.ssh/

WORKDIR /circuits/

RUN wget https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_18.ptau

COPY ./scripts/* /bin/

WORKDIR /app

COPY ./ceremony.env /app

CMD [ "contribute" ]

### image to create ceremonies
FROM node AS zk-ceremony-create

WORKDIR /app

RUN apt update && apt install --no-install-recommends -y -q build-essential curl

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

RUN mkdir -p /temp && cd /temp && \
    git clone https://github.com/iden3/circom.git && \
    cd circom && \
    cargo build --release && \
    cargo install --path circom && \
    npm config set update-notifier false && \
    npm install -g snarkjs circomlib

WORKDIR /circuits/

RUN git clone https://github.com/iden3/circuits.git . && \
    npm ci && \
    #https://github.com/iden3/snarkjs
    wget https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_18.ptau

WORKDIR /app

COPY ./scripts/* /bin/
COPY ./ceremony.env /app

CMD [ "create", "-y" ]
