# check for service enabled

# Save trace setting
_XTRACE_PROMETHEUS_PLUGIN=$(set +o | grep xtrace)
set -o xtrace

echo_summary "devstack-plugin-loki's plugin.sh was called..."
. $DEST/devstack-plugin-loki/devstack/lib/loki

# Show all of defined environment variables
(set -o posix; set)

## Prometheus
if is_service_enabled loki; then
    if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
        # Set up system services
        echo_summary "Configuring system services loki"
        pre_install_loki

    elif [[ "$1" == "stack" && "$2" == "install" ]]; then
        # Perform installation of service source
        echo_summary "Installing loki"
        install_loki

    elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
        # Configure after the other layer 1 and 2 services have been configured
        echo_summary "Configuring loki"
        configure_loki

    elif [[ "$1" == "stack" && "$2" == "test-config" ]]; then
        # Initialize and start the loki service
        echo_summary "Initializing loki"
        init_loki
        echo_summary "Starting loki service"
        start_loki
        echo_summary "Waiting for loki service ready state"
        wait_for_ingester 5
    fi

    if [[ "$1" == "unstack" ]]; then
        # Shut down loki service
        echo_summary "Stoping loki service"
        stop_loki
        echo_summary "Cleaning loki service"
        cleanup_loki
    fi

    if [[ "$1" == "clean" ]]; then
        # Remove state and transient data
        # Remember clean.sh first calls unstack.sh
        echo_summary "Cleaning loki service"
        cleanup_loki
    fi
fi