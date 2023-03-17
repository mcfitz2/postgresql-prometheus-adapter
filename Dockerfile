FROM --platform=$BUILDPLATFORM golang:1.19-alpine AS builder

RUN apk update
RUN apk add git

WORKDIR /opt

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -ldflags "-X main.version=`git describe --tags --always`" -o ./app

FROM scratch

WORKDIR /
COPY --from=builder /opt/app ./postgresql-prometheus-adapter
ENTRYPOINT ["/postgresql-prometheus-adapter"]
