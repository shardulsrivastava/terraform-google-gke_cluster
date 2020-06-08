# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "name_suffix" {
  description = "An arbitrary suffix that will be added to the resource name(s) for distinguishing purposes."
  type        = string
  validation {
    condition     = length(var.name_suffix) <= 14
    error_message = "A max of 14 character(s) are allowed."
  }
}

variable "vpc_network" {
  description = "A reference (self link) to the VPC network to host the cluster in."
  type        = string
}

variable "vpc_subnetwork" {
  description = "A reference (self link) to the subnetwork to host the cluster in."
  type        = string
}

variable "pods_ip_range_name" {
  description = "Name of subnet's secondary IP range for hosting k8s pods."
  type        = string
}

variable "services_ip_range_name" {
  description = "Name of subnet's secondary IP range for hosting k8s services."
  type        = string
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "An arbitrary name to identify the k8s cluster."
  type        = string
  default     = "k8s"
}

variable "node_pool_name" {
  description = "An arbitrary name to identify the GKE node pool and its VMs & VM instance groups."
  type        = string
  default     = "gkenp"
}

variable "ingress_ip_name" {
  description = "An arbitrary name to identify the Ingress IP of the k8s cluster."
  type        = string
  default     = "ingress-ip"
}

variable "sa_name" {
  description = "An arbitrary name to identify the ServiceAccount that will be generated & attached to the k8s cluster nodes."
  type        = string
  default     = "gke"
}

variable "gke_master_version" {
  description = "GKE version of the the cluster master to be used. See https://cloud.google.com/kubernetes-engine/docs/release-notes. "
  type        = string
  default     = "1.15.11-gke.3"
}

variable "cluster_description" {
  description = "The description of the GKE cluster."
  type        = string
  default     = "Generated by Terraform"
}

variable "location_type" {
  description = "Options are \"ZONAL\" (default) or \"REGIONAL\". In \"ZONAL\" clusters, the control-plane exists in a single zone. In \"REGIONAL\" clusters, the control-plane is replicated across multiple zones. Regional clusters contain additional quotas. See \"var.locations\". See https://cloud.google.com/kubernetes-engine/docs/concepts/types-of-clusters#availability."
  type        = string
  default     = "ZONAL"
}

variable "locations" {
  description = "Accepts a list of one or more zone-letters from among \"a\", \"b\", \"c\" or \"d\". Defaults to a single \"a\" zone if nothing is specified here. If \"var.location_type\" is \"ZONAL\", then multiple values can be passed here to make it a \"multi-zonal\" cluster - in which case the control-plane will run in the first specified zone while nodes are replicated in all specified zones.. If \"var.location_type\" is \"REGIONAL\" then the control-plane and the nodes are all replicated in all specified zones. See https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters"
  type        = list(string)
  default     = ["a"]
}

variable "master_authorized_networks" {
  description = "External networks that can access the cluster master(s) through HTTPS."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "enable_private_endpoint" {
  description = "Disables access through the public endpoint of cluster master. Keep it 'false' if you have 'master_authorized_networks_config.cidr_blocks' in the k8s cluster. See https://stackoverflow.com/a/57814380/636762."
  type        = bool
  default     = false
}

variable "namespaces" {
  description = "A list of namespaces to be created in kubernetes."
  type = list(object({
    name   = string
    labels = map(string)
  }))
  default = []
}

variable "secrets" {
  description = "Set of secrets to be created in the different namespaces. Example- {\"namespacename:mysql\": {\"username\": \"johndoe\", \"password\": \"password123\"}}."
  type        = map(map(string))
  default     = {}
}

variable "enable_addon_http_load_balancing" {
  description = "Whether to enable HTTP (L7) load balancing controller addon."
  type        = bool
  default     = true
}

variable "enable_addon_horizontal_pod_autoscaling" {
  description = "Whether to enable Horizontal Pod Autoscaling addon which autoscales based on usage of pods."
  type        = bool
  default     = true
}

variable "machine_type" {
  description = "The size of VM for each node. See https://cloud.google.com/compute/docs/machine-types."
  type        = string
  default     = "e2-micro"
}

variable "disk_type" {
  description = "Type of the disk for each nodes. It can also be `pd-ssd`, which is more costly."
  type        = string
  default     = "pd-standard"
}

variable "disk_size_gb" {
  description = "Size of the disk on each node in Giga Bytes."
  type        = number
  default     = 10
}

variable "preemptible" {
  description = "Preemptible nodes last a maximum of 24 hours and provide no availability guarantees - like spot instances in AWS."
  type        = bool
  default     = false
}

variable "min_node_per_zone" {
  description = "The minimum number of nodes (per zone) this cluster will allocate if auto-down-scaling occurs. Will be re-calibrated to accommodate \"var.initial_node_per_zone\"."
  type        = number
  default     = 1
}

variable "max_node_per_zone" {
  description = "The maximum number of nodes (per zone) this cluster will allocate if auto-up-scaling occurs. Will be re-calibrated to accommodate \"var.initial_node_per_zone\"."
  type        = number
  default     = 2
}

variable "initial_node_per_zone" {
  description = "The initial number of nodes (per zone) for the node pool to begin with. Expected to be a value between \"var.min_node_per_zone\" and \"var.max_node_per_zone\"."
  type        = number
  default     = 1
}

variable "max_surge" {
  description = "Max number of node(s) that can be over-provisioned while the GKE cluster is undergoing a version upgrade. Raising the number would allow more number of node(s) to be upgraded simultaneously."
  type        = number
  default     = 1
}

variable "max_unavailable" {
  description = "Max number of node(s) that can be allowed to be unavailable while the GKE cluster is undergoing a version upgrade. Raising the number would allow more number of node(s) to be upgraded simultaneously."
  type        = number
  default     = 0
}

variable "create_auxiliary_node_pool" {
  description = "Will provision an additional production-grade node_pool. This may cause a surge in your GKE pricing for the duration that this auxiliary pool stays alive. This is meant for temporary use only when an IN-PLACE-UPDATE of the base node_pool is not possible. Create auxiliary pool. TF apply. Make changes to the base node_pool which causes it to be REPLACED. TF apply. Remove auxiliary pool. TF apply."
  type        = bool
  default     = false
}

variable "cluster_logging_service" {
  description = "The logging service to be used by the GKE cluster."
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "cluster_monitoring_service" {
  description = "The monitoring service to be used by the GKE cluster."
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "cluster_timeout" {
  description = "how long a cluster operation is allowed to take before being considered a failure."
  type        = string
  default     = "60m"
}

variable "node_pool_timeout" {
  description = "how long a node pool operation is allowed to take before being considered a failure."
  type        = string
  default     = "30m"
}

variable "namespace_timeout" {
  description = "how long a k8s namespace operation is allowed to take before being considered a failure."
  type        = string
  default     = "5m"
}

variable "sa_roles" {
  description = "The IAM roles that should be granted to the ServiceAccount which is attached to the GKE node VMs. This will enable the node VMs to access other GCP resources as permitted (or disallowed) by the IAM roles."
  type        = list(string)
  default     = []
}

variable "create_static_ingress_ip" {
  description = "Whether to create a new static IP address for ingress"
  type        = bool
  default     = false
}

variable "ip_address_timeout" {
  description = "how long a Compute Address operation is allowed to take before being considered a failure."
  type        = string
  default     = "5m"
}
