#!/usr/bin/env python
try:
    import xmlrpclib
    import shutil
    import sys
    import os.path
    old_system_id = "/tmp/rhn/systemid"
    new_system_id = "/mnt/sysimage/root/systemid.old"
    tmp_key = "/mnt/sysimage/tmp/key"

    new_keys = "1-533973c0d67e7cfb4ebe5dddd2f53559,1-HO-Standard-RHEL-6-Production"
    for key in new_keys.split(','):
        if key.startswith('re-'):
            sys.exit(0)
    if os.path.exists(old_system_id):
        client =  xmlrpclib.Server("http://rhns01.wal-mart.com/rpc/api")
        key = client.system.obtain_reactivation_key(open(old_system_id).read())
        if os.path.exists(tmp_key):
            f = open(tmp_key, "r+")
            contents = f.read()
            if contents and not contents[-1] == ',':
                f.write(',')
        else:
            f = open(tmp_key, "w")
        f.write(key)
        f.close()
        shutil.copy(old_system_id, new_system_id)
except:
    # xml rpc due to  a old/bad system id
    # we don't care about those
    # we'll register those as new.
    pass
