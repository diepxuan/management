<div class="col">
    <div class="vm card border-success" style="width: 18rem;">
        <div class="card-body">
            <h5 class="card-title text-success">{{ $name }}</h5>
            <p class="card-text">
                host private <span class="text-success">{{ $pri_host }}</span>
                <br />
                host public <span class="text-success">{{ $pub_host }}</span>
            </p>
        </div>
        <div class="card-footer bg-transparent">
            <div class="row justify-content-between">
                <div class="col-auto">
                    <form class="d-block" method="post" action="{{ route('admin.vm.update', ['vm' => $id]) }}">
                        @method('PATCH') @csrf
                        <input type="hidden" value="{{ !$is_allow }}" name="is_allow" />
                        <button type="submit" class="form-control form-control-sm btn text-danger">
                            <i class="bi bi-power"></i>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
