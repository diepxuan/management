$(function () {
    $("[vmSettingBtn]").on("click", function () {
        let vmSetting = $(this).closest("[vm]").find("[vmSetting]");
        vmSetting.toggleClass("d-none");

        $(document).mouseup(function (e) {
            if (
                !vmSetting.is(e.target) &&
                vmSetting.has(e.target).length === 0
            ) {
                vmSetting.addClass("d-none");
            }
        });
    });

    $("[vmClients]").each(function (index, vm) {
        let vm_id = $(vm).attr("vmClients");
        $(this).append($("[vmParent='" + vm_id + "']"));
    });
});
