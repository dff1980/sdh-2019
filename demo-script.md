# Demo Script (Apr. 2019 SAP Forum)
## SUSE part demo script
1. Demonstrate SES Web interface (from VPN http://sdh.suse.ru openattic/{default password}):
   1. Grafana data
   2. Pool/RBD state
   3. Current node state (Details & Statistics)
2. Demonstrate CLI interface (ssh root@sdh.suse.ru):
   1. Cluster state
   ```pshell
   plink -load SDH-router -batch ceph -s
   ```
   2. Data list
   ```pshell
   plink -load SDH-router -batch rbd list
   plink -load SDH-router -batch rbd info {Object ID)
   ```
3. Demonstrate SUSE CaaSP Velum web interface (from VPN https://sdh.suse.ruroot@master.sdh.suse.ru/{project default password}):
   1. Node state
   2. Current settings
4. Demonstrate SUSE CaaSP Velum Dashboard/web tools:
   1. Current state, grafana integration
   2. Create/delete pods (nginx)
   3. Demonstrate Weave interface
3. Demostrate CLI interface
   1. Cluster state
   2. Pod's control
   3. Helm's commands interface
   ```bash
   cd microservices-demo
   kubectl create namespace shop
   helm install suse-shop --namespace shop
   ```
   Demonstrate Web from kubectl proxy.
   ```bash
   kubectl apply -f ingress.yaml -n shop
   ```
   Demonstrate 2, and more Shop in different namespaces.
   ```bash
   kubectl delete namespaces shop
   ```
   Demonstrate Weave interface

   Addon service demo (change apple)
   cat ingress.yaml | sed s/\$\$NAME/apple/ | kubectl create -f -

## Prepare Demo

#### Container Deployment Demo Deploy

You’ve prepared everything now. So we’re going to show how easy it is to show the dashboard and then deploy something.
Switch to the dashboard and choose your namespace from the dropdown on the left and show that nothing is there.
Then click create up the top right and type nginx under both app name and container image you will need to click the “show advanced options” blue link above deploy at the bottom and in the advanced options change namespace to match your city name you created earlier
However; what about more complex deployments?
You will run helm install suse-shop --namespace london (replace London with your city from earlier) to deploy the soc/suse shop
You will then run kubectl get deployments -n london (replace London with your country)

To reset your namespace you can delete and re-create your namespace.
If however you’ve already done a “helm install” command please do the following first:
“helm list”
On the list that comes out on the far right collum (namespace) you will see one for your city. What you’re looking for is the name (furthest collum to the left) that relates to your city namespace. (it will be 2 random words separated by a hyphen). Once you have this you run:
“helm delete random-words” (replacing random-words with the NAME of your deployment identified just now). Then run the following 2 kbectl commands to reset your demo back to the point where you can start again from slide 
“kubectl delete namespace london” (change london to your city)
Then run
“kubectl create namespace london” (change london to your city)

## Prepare Client Enviroment

### Connect to OpenAttic (SES Web interface)
from VPN http://sdh.suse.ru openattic/{default password}

### Connect to Velum (CaaS admin web interface)
from VPN https://sdh.suse.ru root@master.sdh.suse.ru/{project default password}

### Connect to K8S CLI interface
On your windows machine do the following:
Click start and type “power” and look for power shell. Right click it and run as administrator.
Then run the following:
```pshell
Set-ExecutionPolicy AllSigned 

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```
Accept all prompts. You have now installed chocolatey. If you run into issues on this page try following the instructions at https://chocolatey.org/install making sure you’re using powershell as the easier interpreter to copy/paste into

Now we need to install kubectl and helm
In the same admin powershell window run:
```pshell
choco install kubernetes-cli
choco install git
```
Accept all prompts/scripts with y.
Download and extract the file from https://storage.googleapis.com/kubernetes-helm/helm-v2.7.2-windows-amd64.tar.gz and copy the extracted helm.exe file to C:\Windows\System32
You will need to close and reload (as an admin) your powershell window to enable git to work (it reloads the path)
You have now accepted and installed git, helm and kubectl

Now we need to get the code. In the same window run:
cd ~
mkdir .kube

Copy the kubectl config file that resides in this directoy (also sent to the expert-days mailing list) into the .kube directory (so it is ~/.kube/config) from the email you received. It’s easiest to put it into Downloads then do a mv Downloads/config .kube/config Then run:
helm init --client-only

The final thing to do before starting the caasp presentation is to run:
“kubectl proxy --port=8000”
(you will have to do this in a new powershell window and minimise it as you can’t run further commands afterwards)
Then go to http://localhost:8000/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard to load up the dashboard (copy and paste this URL).Once in the dashboard, under namespace on the left where it says default click the dropdown and change this to the namespace you created just now. The dashboard should not show anything deployed under your namespace at this point in time.
You are now ready for the demo.
cd to the microservices-demo folder you checked out in your home directory
When you actually do the deployment (NOT NOW!!!!!!!) you will be applying the helm chart located in the folder suse-shop. DO NOT CD INTO suse-shop AS THIS WILL NOT WORK YOU RUN THE HELM COMMAND INSIDE THE microservices-demo FOLDER


https://drive.google.com/open?id=1HFz0HdsP_T9u5tU5zESLK5U6scstYao5

