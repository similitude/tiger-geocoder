FROM postgis:2.1

MAINTAINER Oliver Lade <piemaster21@gmail.com>
# See https://www.census.gov/geo/maps-data/data/tiger-line.html
# See http://www.peterstratton.com/2014/04/your-own-private-geocoder-using-postgis-and-ubuntu/

# Install system dependencies.
RUN apt-get update
RUN apt-get install -qq wget python unzip

#RUN wget -q ftp://ftp2.census.gov/geo/tiger/TIGER2014/TRACT/tl_2014_06_tract.zip
#RUN wget -q http://censusdata.ire.org/06/all_140_in_06.P1.csv
#RUN wget -q -O - http://censusdata.ire.org/06/all_140_in_06.P1.csv | zcat > all_140_in_06.P1.csv

RUN wget -q http://postgis.net/stuff/postgis-2.1.5dev.tar.gz
RUN tar xvfz postgis-2.1.5dev.tar.gz


ENV PGDATA /usr/local/pgsql/data
ENV PGUSER docker
ENV PGPASSWORD docker
RUN echo "local    all             docker                              md5" > /etc/postgresql/9.3/main/pg_hba.conf



RUN sed -i 's/pgsql-9.0\///' postgis-2.1.5dev/extras/tiger_geocoder/tiger_2011/tiger_loader_2013.sql
RUN sed -i '/PGUSER/d' postgis-2.1.5dev/extras/tiger_geocoder/tiger_2011/tiger_loader_2013.sql
RUN sed -i '/PGPASSWORD/d' postgis-2.1.5dev/extras/tiger_geocoder/tiger_2011/tiger_loader_2013.sql

RUN sed -i '/PGUSER/d' postgis-2.1.5dev/extras/tiger_geocoder/tiger_2011/create_geocode.sh
RUN sed -i '/PGPASSWORD/d' postgis-2.1.5dev/extras/tiger_geocoder/tiger_2011/create_geocode.sh
RUN sed -i '/\${PSQL_CMD}/ s/-d/-v ON_ERROR_STOP=1 -d/' postgis-2.1.5dev/extras/tiger_geocoder/tiger_2011/create_geocode.sh
RUN sed -i '/search_path/ s/#//' postgis-2.1.5dev/extras/tiger_geocoder/tiger_2011/create_geocode.sh

RUN service postgresql start && \
        createdb geocoder && \
        psql -d geocoder -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql && \
        psql -d geocoder -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql && \
        psql -d geocoder -c "CREATE EXTENSION fuzzystrmatch" && \
        cd postgis-2.1.5dev/extras/tiger_geocoder/tiger_2011 && ./create_geocode.sh && \
        service postgresql stop

RUN service postgresql start && \
        psql -d geocoder -c "SELECT pprint_addy(normalize_address('202 East Fremont Street, Las Vegas, Nevada 89101')) As pretty_address;" && \
        service postgresql stop
        
#RUN tar xvf -z all_140_in_06.P1.csv

#RUN unzip tl_2014_06_tract.zip

# RUN ./start.sh




#RUN service postgresql start && \
#        createdb ca-census && \
#        psql -d ca-census -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql && \
#        psql -d ca-census -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql && \
#        shp2pgsql -D -s 4269 -I tl_2014_06_tract.shp ca_census_tracts | \
#        psql -d ca-census && \
#        
#        psql -d ca-census -c "CREATE TABLE ca_census_data (GEOID varchar(11), SUMLEV varchar(3), \
#        STATE varchar(2), COUNTY varchar(3), CBSA varchar(5), CSA varchar(3), \
#        NECTA integer, CNECTA integer, NAME varchar(30), POP100 integer, \
#        HU100 integer, POP1002000 integer, HU1002000 integer, P001001 integer, \
#        P0010012000 integer);" && \
#        service postgresql stop

#RUN sed -i '1!b;s/\.//' all_140_in_06.P1.csv

#RUN service postgresql start && \
#        cat all_140_in_06.P1.csv | psql -d ca-census -c 'COPY ca_census_data FROM STDIN WITH CSV HEADER' && \
#        service postgresql stop


#RUN sleep 2

#RUN shp2pgsql -D -s 4269 -I tl_2014_06_tract.shp census_ca_tracts | psql -d census-ca

#CMD echo 'hello'

# RUN tar xzf netlogo-5.1.0.tar.gz && rm netlogo-5.1.0.tar.gz
# RUN mv netlogo-5.1.0 /opt/netlogo

#createdb dc-census
#createlang plpgsql dc-census
#psql -d dc-census -f postgis.sql
#psql -d dc-census -f spatial_ref_sys.sql


# Copy the API directory across.
#ADD api /api

# Install Python wrapper script dependencies.
#RUN apt-get install -qq python-lxml
