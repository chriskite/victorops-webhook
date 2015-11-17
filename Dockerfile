FROM phusion/baseimage:0.9.17

# set locale
RUN locale-gen --no-purge en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y git build-essential libssl-dev zlib1g-dev libreadline-dev libyaml-dev ca-certificates

# Ruby
# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv && git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN /root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh && echo 'eval "$(rbenv init -)"' >> /root/.bashrc

# Install specified ruby
ENV CONFIGURE_OPTS --disable-install-doc
ADD .ruby-version /root/versions.txt
RUN xargs -L 1 rbenv install < /root/versions.txt
# Install Bundler
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN bash -l -c 'for v in $(cat /root/versions.txt); do rbenv global $v; gem install --no-ri --no-rdoc bundler; done'

ADD Gemfile /victorops-webhook/
ADD Gemfile.lock /victorops-webhook/
WORKDIR /victorops-webhook
RUN /bin/bash -l -c "bundle install --deployment"

ADD . /victorops-webhook

CMD /root/.rbenv/shims/bundle exec ruby lib/victorops-webhook.rb
