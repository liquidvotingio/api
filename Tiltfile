k8s_yaml([
  'k8s/ingress.yaml',
  'k8s/database-persistent-volume-claim.yaml',
  'k8s/database-service.yaml',
  'k8s/database-deployment.yaml',
  'k8s/liquid-voting-service.yaml',
  'k8s/liquid-voting-deployment.yaml'
])

docker_build('oliverbarnes/liquid-voting-service', '.')
