FROM alpine:latest AS build
RUN echo "http://mirror.leaseweb.com/alpine/edge/testing" >> /etc/apk/repositories
RUN apk add --no-cache libc-dev
RUN apk add --no-cache gfortran
RUN apk add --no-cache hdf5-dev
RUN apk add --no-cache make
RUN apk add --no-cache cmake
RUN apk add --no-cache perl
RUN apk add --no-cache python3
COPY --from=steabert/openblas:latest /opt/OpenBLAS /opt/OpenBLAS
ADD . OpenMolcas
WORKDIR OpenMolcas
RUN mkdir build/
WORKDIR build/
RUN cmake -DLINALG=OpenBLAS -DOPENBLASROOT=/opt/OpenBLAS -DHDF5=ON ../
RUN make
RUN make install

FROM alpine:latest AS runtime
RUN echo "http://mirror.leaseweb.com/alpine/edge/testing" >> /etc/apk/repositories
RUN apk add --no-cache libgfortran
RUN apk add --no-cache hdf5
RUN apk add --no-cache python3 py3-parsing
COPY --from=steabert/openblas:latest /opt/OpenBLAS /opt/OpenBLAS
COPY --from=build /opt/molcas /opt/molcas
ENV MOLCAS /opt/molcas
RUN mkdir /scratch
WORKDIR /scratch
ENTRYPOINT ["/opt/molcas/sbin/pymolcas"]
