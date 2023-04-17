<div vm="{{ $vm_id }}" vmParent="{{ $parent_id }}" class="row row-cols-auto">
    <div class="col">
        <div class="card border-disable text-black-50" style="width: 18rem;">
            <div class="card-body">
                <h5 class="card-title">{{ $name }}</h5>
                <p class="card-text">
                    host private <span class="text-disable">{{ $pri_host }}</span><br />
                    host public <span class="text-disable">{{ $pub_host }}</span><br />
                </p>
            </div>
            <div class="card-footer bg-transparent">
                <div class="row justify-content-between">
                    <div class="col-auto">
                        <form class="d-block" method="post" action="{{ route('admin.vm.update', ['vm' => $vm_id]) }}">
                            @method('PATCH') @csrf
                            <input type="hidden" value="{{ $is_allow ? 0 : 1 }}" name="is_allow" />
                            <button type="submit" class="form-control form-control-sm btn text-primary">
                                <i class="bi bi-power"></i>
                            </button>
                        </form>
                    </div>
                    <div class="col-auto">
                        <form class="d-block" method="post" action="{{ route('admin.vm.destroy', ['vm' => $vm_id]) }}">
                            @method('DELETE') @csrf
                            <input type="hidden" value="{{ $vm_id }}" name="vm" />
                            <button type="submit" class="form-control form-control-sm btn text-danger">
                                <i class="bi bi-trash"></i>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div vmClients="{{ $vm_id }}" class="col">
    </div>
</div>
