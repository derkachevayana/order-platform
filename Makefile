.PHONY: dev-up dev-down k3d-up k3d-down

dev-up:
	docker compose up -d

dev-down:
	docker compose down

k3d-up:
	@echo "Checking if k3d cluster 'order-platform' already exists..."
	@if k3d cluster list order-platform >/dev/null 2>&1; then \
		echo "Cluster exists. Starting it (if stopped)..."; \
		k3d cluster start order-platform; \
	else \
		echo "Cluster not found. Creating a new one..."; \
		k3d cluster create order-platform; \
	fi
	@$(MAKE) k3d-deploy

k3d-deploy:
	@echo "Deploying/Updating all Helm charts..."
	helm upgrade --install auth-service ./helm/auth-service
	helm upgrade --install user-service ./helm/user-service
	helm upgrade --install api-gateway ./helm/api-gateway
	helm upgrade --install order-service ./helm/order-service
	helm upgrade --install payment-service ./helm/product-service
	helm upgrade --install inventory-service ./helm/inventory-service
	helm upgrade --install notification-service ./helm/notification-service
	@echo "All services are up-to-date in Kubernetes!"

k3d-stop:
	@echo "Putting cluster to sleep..."
	k3d cluster stop order-platform

k3d-start:
	@echo "Waking up cluster..."
	k3d cluster start order-platform

k3d-down:
	@echo "Deleting k3d cluster completely..."
	k3d cluster delete order-platform
