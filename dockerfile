FROM rocker/r-ver:3.5.0

RUN apt-get update -qq && apt-get install -y \
      libssl-dev \
      libcurl4-gnutls-dev
      
RUN R -e "install.packages('plumber')"
RUN R -e "install.packages('tidyverse')"
RUN R -e "install.packages('httr')"
RUN R -e "install.packages('SnowballC')"
RUN R -e "install.packages('tm')"
RUN R -e "install.packages('tidytext')"
RUN R -e "install.packages('stringr')"


COPY / /

EXPOSE 8000

ENTRYPOINT ["Rscript", "Main.R"]