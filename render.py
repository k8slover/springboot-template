import yaml
from jinja2 import Environment, FileSystemLoader
import os

with open('values.yaml') as f:
    values = yaml.safe_load(f)

env = Environment(loader=FileSystemLoader('manifests'))
template = env.get_template('deployment.yaml.j2')
rendered = template.render(values)

os.makedirs('rendered', exist_ok=True)
with open('rendered/deployment.yaml', 'w') as f:
    f.write(rendered)
