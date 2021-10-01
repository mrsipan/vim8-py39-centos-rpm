Build `vim8` with `python39` rpm
================================

Run:

.. source-code:: bash

     docker run -w /build -v $PWD:/build \
       --rm -it centos:8 /build/build.sh v8.2.3459


