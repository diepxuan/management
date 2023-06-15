$(function () {
    $("[vmSettingBtn]").on("click", function () {
        let vm_id = $(this).closest("[vm]").attr("vm");
        $("[vmSetting='" + vm_id + "']").toggleClass("d-none");
    });

    $("[vmClients]").each(function (index, vm) {
        let vm_id = $(vm).attr("vmClients");
        $(this).append($("[vmParent='" + vm_id + "']"));
    });

    $(document).mouseup(function (e) {
        if (
            !$("[vmSetting]").is(e.target) &&
            $("[vmSetting]").has(e.target).length === 0
        ) {
            $("[vmSetting]").addClass("d-none");
        }
    });
});
