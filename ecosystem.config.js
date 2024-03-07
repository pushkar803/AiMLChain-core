module.exports = {
    apps : [{
      name: 'chain_node_0',           // Name of the running script in PM2
      script: './AiMLChain_server',      // Path to the script to be executed
      args: '3',             // Space-separated arguments to pass to the script
      instances: 1,                  // Number of instances to run (useful for clustering)
      autorestart: true,             // Whether to restart the script if it crashes
      watch: false,                  // Whether to restart on file changes
      max_memory_restart: '1G',      // Restart the script if it exceeds this memory usage
      env: {
        NODE_ENV: 'development',     // Environment variables for development
      },
      env_production: {
        NODE_ENV: 'production',      // Environment variables for production
      }
    },
    {
        name: 'chain_node_1',           // Name of the running script in PM2
        script: './AiMLChain_server',      // Path to the script to be executed
        args: '4',             // Space-separated arguments to pass to the script
        instances: 1,                  // Number of instances to run (useful for clustering)
        autorestart: true,             // Whether to restart the script if it crashes
        watch: false,                  // Whether to restart on file changes
        max_memory_restart: '1G',      // Restart the script if it exceeds this memory usage
        env: {
          NODE_ENV: 'development',     // Environment variables for development
        },
        env_production: {
          NODE_ENV: 'production',      // Environment variables for production
        }
      }]
  };
  