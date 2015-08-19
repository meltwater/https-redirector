import os, subprocess, optparse, logging
from mako.template import Template

def parsebool(value):
    truevals = set(['true', '1'])
    falsevals = set(['false', '0'])
    stripped = str(value).lower().strip()
    if stripped in truevals:
        return True
    if stripped in falsevals:
        return False
    
    logging.error("Invalid boolean value '%s'", value)
    sys.exit(1)


parser = optparse.OptionParser(
    usage='docker run -p 80:80 meltwater/redirector:latest [options]...',
    description='Redirects all HTTP requests to HTTPS')

parser.add_option('--proxy-protocol', dest='proxyprotocol', help='Enable proxy protocol on nginx [default: %default]',
    action="store_true", default=parsebool(os.environ.get('PROXY_PROTOCOL', False)))

parser.add_option('-v', '--verbose', dest='verbose', help='Increase logging verbosity',
    action="store_true", default=parsebool(os.environ.get('VERBOSE', False)))

(options, args) = parser.parse_args()

if options.verbose:
    logging.getLogger().setLevel(logging.DEBUG)
else:
    logging.getLogger().setLevel(logging.INFO)

if options.proxyprotocol:
	logging.info("Enabling PROXY protocol")

# Expand the config template
template = Template(filename='/etc/nginx/conf.d/default.conf.tpl')
config = template.render(proxyprotocol=options.proxyprotocol)
with open('/etc/nginx/conf.d/default.conf', 'w') as f:
    f.write(config)

# Start nginx
subprocess.call('nginx', shell=True)
