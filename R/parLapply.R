run_parLapply = function(config){
  config$cluster = makePSOCKcluster(config$jobs)
  clusterExport(cl = config$cluster, varlist = "config",
    envir = environment())
  clusterCall(cl = config$cluster, fun = do_prework, 
    config = config)
  run_parallel(config = config, worker = worker_parLapply)
  stopCluster(cl = config$cluster)
}

worker_parLapply = function(targets, hash_list, config){
  parLapply(cl = config$cluster, X = targets, fun = build, 
    hash_list = hash_list, config = config)
}