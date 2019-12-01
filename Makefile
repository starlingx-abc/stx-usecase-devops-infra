all:
	rm -f stx-devops-1.0.0.tgz
	rm -rf armada/charts
	mkdir -p armada/charts
	cd charts && tar czf ../armada/charts/stx-devops-1.0.0.tgz stx-devops
	cd armada && find charts metadata.yaml stx-devops.yaml -type f -exec md5sum {} \; > checksum.md5
	cd armada && tar czf ../stx-devops-1.0.0.tgz *
	#rm -rf armada/charts armada/checksum.md5
