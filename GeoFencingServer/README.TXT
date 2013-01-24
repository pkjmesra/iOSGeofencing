A geofencing server that can run on a Mac (SDK 10.7 or above). When running, this would provide services to iOs clients. Point your Mac browser to http://127.0.0.1:<port the server is running on> for a list of all services

By default, it would run on 1208. So you can just run and check your Mac browser on http://127.0.0.1:1208 for all the APIs that this server will expose for its iOS clients.

You'd need to add your own apns.cer push notification certificate to be able to use push notification services.
