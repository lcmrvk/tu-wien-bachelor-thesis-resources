
# Acknowledgements

Thanks to [dinfuehr](https://gist.github.com/dinfuehr) whose work I used as a
basis for creating the Dockerfile for Cacao  [dockerfile-cacao-dinfuehr](https://gist.github.com/dinfuehr/ab83ad825cd24be0e816588d0465a7fb) and thanks to [Jozott00](https://github.com/Jozott00)
for finding the time to discuss some issues with building Cacao and pointing me in the direction of his setup [cacao-jvm-dev-setup](https://github.com/Jozott00/cacao-jvm-dev-setup/tree/master).

# Getting Started

To get started you are going to need to have Docker installed. It's not strictly
necessary, but very convenient to also install docker-compose.

# How to use

Once these are installed you can run `docker-compose build` from within the
directory where the `docker-compose.yml` file is located. This will build all
JVMs declared there. If you want to build only a single one, you can run
`docker-compose build <service-name>` where `<service-name>` is one of the
services declared in `docker-compose.yml`.

Note, that if you are planning to use the `run-dacapo.sh` or `run-spec2008.sh`
scripts to benchmark these JVMs, you will need to get those script into the
image/container yourself. Alternatively you might want to use a bind mount to
achieve that. The same is true for the benchmarks themselves. The above
mentioned scripts expect the files `SPECjvm2008.jar` / `dacapo-2006-10-MR2.jar`
to be in the same directory as those scripts. The scripts themselves need to be
be executed from within the same directory within which they are located.
