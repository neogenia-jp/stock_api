FROM neogenia/stock_api_rails:202104

# updata hpdft
RUN cd /tmp \
 && cd hpdft \
 && git pull \
 && git checkout 854fc11d6d94975fa0705a21cdc2db17f0427dcd \
 && cabal update \
 && cabal install --bindir=/usr/local/bin
