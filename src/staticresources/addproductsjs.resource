function init(){
    Visualforce.remoting.Manager.invokeAction("AddProductsController.getOptions", window.__APEX_VARS__.PRICEBOOK.ID, function(result, event){
        $("select").each(function(index, select){
            if($(select).attr("options") != null){ addOptions(select, result[$(select).attr("options")]); }
        });
        var catalog = result["products"];
        var product_options = $();
        for(var key in catalog){
            if(catalog.hasOwnProperty(key)){
                var option = document.createElement('option');
                option.value = catalog[key];
                option.text = key;
                product_options = product_options.add(option);
            }
        }
        $("#product").append(product_options);
    });

    $("#account-hierarchy").jstree({
        "core": {
            "themes": {
                "variant": "large"
            },
            "data": function(node, cb){
                loadNodes(this, node, cb);
            },
            check_callback: true
        },
        "checkbox": {
            "keep_selected_style": false
        },
        "plugins": [ "themes", "contextmenu", "dnd", "search", "types" ],
        contextmenu: {
            "items": function(node){
                var items = {};
                var tree = $("#account-hierarchy").jstree(true);
                if(node.type != "product"){
                    items["view"] = {
                        label: "View",
                        action: function(object){
                            window.open("/" + node.id, "_blank");
                        }
                    };
                }
                items["edit"] = {
                    label: "Edit",
                    action: function(object){
                        document.forms[node.type + "-form"].reset();
                        $(document.forms[node.type + "-form"].elements).each(function(index, element){
                            if($(element).hasClass("has-error")) {
                                $(element).removeClass("has-error");
                                $(element).attr("placeholder", "");
                            }
                        });
                        $(document.forms[node.type + "-form"]).data(node.type + "_id", node.id);
                        $(document.forms[node.type + "-form"].elements).each(function(index, element){
                            if($(element).attr("fieldname") != null){
                                if($(element).attr("type") == "checkbox"){
                                    console.log(node.original.record.get($(element).attr("fieldname")));
                                    $(element).prop("checked", node.original.record.get($(element).attr("fieldname")));
                                }
                                else{
                                    $(element).val(node.original.record.get($(element).attr("fieldname")));
                                }
                            }
                        });
                        if(node.type == "contact"){
                            if(node.original.record.get("Qualification__c") == null) $("#contact-qualification").html("Not Qualified");
                            else{$("#contact-qualification").html(node.original.record.get("Qualification__c"));}
                        }
                        if(node.type == "product") $("#product").prop("disabled", true);
                        $("#" + node.type + "-dialog-header").text(node.text);
                        $("#" + node.type + "-dialog").show();
                    }
                };
                if(node.type == "account"){
                    var add_items = {};
                    add_items["account"] = {
                        label: "Account",
                        action: function(object){
                            document.forms["account-form"].reset();
                            $(document.forms["account-form"].elements).each(function(index, element){
                                if($(element).hasClass("has-error")) {
                                    $(element).removeClass("has-error");
                                    $(element).attr("placeholder", "");
                                }
                            });
                            $(document.forms["account-form"]).data("parent", node);
                            $(document.forms["account-form"]).data("account_id", null);
                            $("#account-dialog-header").text("New Account");
                            $("#account-dialog").show();
                            $("#account-name").focus();
                        }
                    };
                    add_items["contact"] = {
                        label: "Contact",
                        action: function(object){
                            document.forms["contact-form"].reset();
                            $(document.forms["contact-form"].elements).each(function(index, element){
                                if($(element).hasClass("has-error")) {
                                    $(element).removeClass("has-error");
                                    $(element).attr("placeholder", "");
                                }
                            });
                            $("#contact-qualification").text("Not Qualified");
                            $(document.forms["contact-form"]).data("parent", node);
                            $(document.forms["contact-form"]).data("contact_id", null);
                            $("#contact-dialog-header").text("New Contact");
                            $("#contact-dialog").show();
                            $("#contact-first-name").focus();
                        }
                    };
                    var show_product_item = true;
                    $(node.children).each(function(index, value){
                        if(tree.get_type(value) == "account"){
                            show_product_item = false;
                        }
                    });
                    if(show_product_item){
                        add_items["product"] = {
                            label: "Product",
                            action: function(object){
                                document.forms["product-form"].reset();
                                $(document.forms["product-form"]).data("parent", node);
                                $(document.forms["product-form"]).data("product_id", null);
                                $("#product-dialog-header").text("Add Product");
                                $("#product-dialog").show();
                                $("#product").prop("disabled", false).focus();
                            }
                        };
                    }
                    items["add"] = {
                        label: "Add",
                        submenu: add_items
                    };
                }
                if(tree.get_parent(node) != "#"){
                    items["delete"] = {
                        label: "Delete",
                        action: function(){
                            $("#prompt-dialog").data("node", node);
                            $("#prompt-message").html("Are you sure you want to <strong>permanently</strong> delete " + node.text + "?");
                            $("#prompt-dialog").show();
                        }
                    };
                }
                return items;
            },
            "select_node": false
        },
        "dnd": {
            "is_draggable": function(nodes){
                var hasProduct = false;
                $(nodes).each(function(index, value){
                    if(value.type == "product"){
                        hasProduct = true;
                    }
                });
                return !hasProduct;
            }
        },
        "types": {
            "account": {
                "valid_children": [ "account", "contact", "product" ]
            },
            "contact": {
                "icon": "/img/icon/profile16.png",
                "valid_children": [ "none" ]
            },
            "product": {
                "icon": "/img/icon/star16.png",
                "valid_children": [ "none" ]
            }
        }
    }).on("after_open.jstree", function(){
    
    }).on("move_node.jstree", function(event, data){
        moveNode(data);
    }).on("select_node.jstree", function(event, data){
        if(data.node.type == "contact"){
            selectInfluence(data.node);
        }
    }).on("loaded.jstree", function(){
        $(this).jstree("open_all");
    });
    //EVENT LISTENERS.
    $("#account-dialog-cancel").click(function(){ $("#account-dialog").hide("fade"); });
    $("#account-dialog-save").click(function(){
        var parent = $(document.forms["account-form"]).data("parent");
        var account_id = $(document.forms["account-form"]).data("account_id");
        var errors = [];
        $(document.forms["account-form"].elements).each(function(index, element){
            if(!element.checkValidity()){
                $(element).addClass("has-error");
                $(element).attr("placeholder", element.validationMessage);
                errors.push($(element).siblings("label").text() + ": " + element.validationMessage);
            }
        });
        if(errors.length > 0){
            console.log(errors);
        }
        else{
            var account = new SObjectModel.Account();
            if(parent != null) account.set("ParentId", parent.id);
            if(account_id != null) account.set("Id", account_id);
            $(document.forms["account-form"].elements).each(function(index, element){
                if($(element).attr("fieldname") != null){
                    if($(element).attr("type") == "checkbox"){
                        account.set($(element).attr("fieldname"), $(element).prop("checked"));
                    }
                    else{
                        account.set($(element).attr("fieldname"), $(element).val());
                    }
                }
            });
            account.upsert(function(error){
                if(error){
                    notify(error);
                }
                else{
                    $("#account-dialog").hide("fade");
                    var tree = $("#account-hierarchy").jstree(true);
                    if(account_id == null){
                        //This was an INSERT.
                        var new_node = {
                            id: account.get("Id"),
                            record: account,
                            text: account.get("Name"),
                            type: "account"
                        };
                        var id = tree.create_node(parent, new_node, "last", null, true);
                        if(tree.is_closed(parent)){
                            tree.open_node(parent, function(){
                                tree.deselect_node(parent);
                                tree.select_node(new_node);
                            });
                        }
                        else{
                            tree.deselect_node(parent);
                            tree.select_node(new_node);
                        }
                    }
                    else{
                        //This was an UPDATE.
                        var node = tree.get_node(account.get("Id"));
                        node.original.record = account;
                        if(node.text != account.get("Name")){
                            tree.rename_node(node, account.get("Name"));
                        }
                    }
                }
            });
        }
    });
    $("#account-name").keyup(function(){
        if($(this).val() == ""){
            $("#account-dialog-header").text("New Account");
        }
        else{
            $("#account-dialog-header").text($(this).val());
        }
    });
    $("#back-button").click(function(){window.location.href = "javascript:history.back()";});
    $("#contact-dialog-cancel").click(function(){ $("#contact-dialog").hide("fade"); });
    $("#contact-dialog-save").click(function(){
        var parent = $(document.forms["contact-form"]).data("parent");
        var contact_id = $(document.forms["contact-form"]).data("contact_id");
        var errors = [];
        var contact = new SObjectModel.Contact();
        if(parent != null) contact.set("AccountId", parent.id);
        $(document.forms["contact-form"].elements).each(function(index, element){
            if(!element.checkValidity()){
                $(element).addClass("has-error");
                $(element).attr("placeholder", element.validationMessage);
                errors.push($(element).siblings("label").text() + ": " + element.validationMessage);
            }
        });
        if(errors.length > 0){
            console.log(errors);
        }
        else{
            if(contact_id != null) contact.set("Id", contact_id);
            $(document.forms["contact-form"].elements).each(function(index, element){
                if($(element).attr("fieldname") != null){
                    if($(element).attr("type") == "checkbox"){
                        contact.set($(element).attr("fieldname"), $(element).prop("checked"));
                    }
                    else{
                        contact.set($(element).attr("fieldname"), $(element).val());
                    }
                }
            });
            contact.upsert(function(error){
                if(error){
                    notify(error);
                }
                else{
                    $("#contact-dialog").hide("fade");
                    var tree = $("#account-hierarchy").jstree(true);
                    if(contact_id == null){
                        //This was an INSERT.
                        var new_node = {
                            id: contact.get("Id"),
                            record: contact,
                            text: contact.get("FirstName") + " " + contact.get("LastName"),
                            type: "contact"
                        };
                        var id = tree.create_node(parent, new_node, "first", null, true);
                        if(tree.is_closed(parent)){
                            tree.open_node(parent, function(){
                                tree.deselect_all(true);
                                tree.select_node(new_node);
                            });
                        }
                        else{
                            tree.deselect_all(true);
                            tree.select_node(new_node);
                        }
                    }
                    else{
                        //This was an UPDATE.
                        var node = tree.get_node(contact.get("Id"));
                        node.original.record = contact;
                        if(node.text != contact.get("FirstName") + " " + contact.get("LastName")){
                            tree.rename_node(node, contact.get("FirstName") + " " + contact.get("LastName"));
                        }
                    }
                }
            });
        }
    });
    $(".contact-name").keyup(function(){
        if($("#contact-first-name").val() == "" && $("#contact-last-name").val() == ""){
            $("#contact-dialog-header").text("New Contact");
        }
        else{
            $("#contact-dialog-header").text($("#contact-first-name").val() + " " + $("#contact-last-name").val());
        }
    });
    $("#help-button").click(function(){window.open("https://www.youtube.com/watch?v=1PWk3i9WT-8", "_blank");});
    $("#hierarchy-header").click(function(){$("#account-hierarchy").slideToggle();});
    $("input").change(function(){
        if($(this).hasClass("has-error") && $(this).val() != ""){
            $(this).removeClass("has-error");
            $(this).attr("placeholder", "");
        }
    });
    $("#notification-close").click(function(){$("#notification").hide("fade");});
    $(".phone-number").change(function(){ formatPhone(this); });
    $("#product-dialog-save").click(function(){
        var parent = $(document.forms["product-form"]).data("parent");
        var product_id = $(document.forms["product-form"]).data("product_id");
        var errors = [];
        var product = new SObjectModel.OpportunityLineItem({UnitPrice: 0});
        if(parent != null) product.set("Account__c", parent.id);
        $(document.forms["product-form"].elements).each(function(index, element){
            if(!element.checkValidity()){
                $(element).addClass("has-error");
                $(element).attr("placeholder", element.validationMessage);
                errors.push($(element).siblings("label").text() + ": " + element.validationMessage);
            }
        });
        if(errors.length > 0) {
            console.log(errors);
        }
        else {
            if(product_id != null) product.set("Id", product_id);
            else{
                product.set("OpportunityId", window.__APEX_VARS__.OPPORTUNITY_ID);
                product.set("PricebookEntryId", $("#product").val());
            }
            product.set("Quantity", $("#product-quantity").val());
            product.upsert(function(error){
                if(error){
                    notify(error);
                }
                else {
                    $("#product-dialog").hide("fade");
                    var tree = $("#account-hierarchy").jstree(true);
                    if(product_id == null){
                        //This was an INSERT.
                        var new_node = {
                            id: product.get("Id"),
                            product_code: $("#product option:selected").text(),
                            record: product,
                            text: $("#product option:selected").text() + " (" + product.get("Quantity") + ")",
                            type: "product"
                        };
                        var id = tree.create_node(parent, new_node, "first", null, true);
                        if(tree.is_closed(parent)){
                            tree.open_node(parent, function(){
                                tree.deselect_all(true);
                                tree.select_node(new_node);
                            });
                        }
                        else{
                            tree.deselect_all(true);
                            tree.select_node(new_node);
                        }
                    }
                    else{
                        //This was an UPDATE.
                        var node = tree.get_node(product.get("Id"));
                        node.original.record.set("Quantity", product.get("Quantity"));
                        if(node.text != node.original.product_code + " (" + product.get("Quantity") + ")"){
                            tree.rename_node(node, node.original.product_code + " (" + product.get("Quantity") + ")");
                        }
                    }
                }
            });
        }
    });
    $("#product-dialog-cancel").click(function(){ $("#product-dialog").hide("fade"); });
    $("#product").change(function(){
        if ($(this).val() !== "") {
            $("#product-dialog-header").text("Add " + $("#product option:selected").text() + ($("#product-quantity").val() === "" ? "" : " (" + $("#product-quantity").val() + ")"));
        }
        else {
            $("#product-dialog-header").text("Add Product");
        }
    });
    $("#product-form").submit(function(){
        return false;
    });
    $("#product-quantity").keyup(function(){
        if ($("#product").val() !== "") {
            $("#product-dialog-header").text("Add " + $("#product option:selected").text() + ($(this).val() === "" ? "" : " (" + $(this).val() + ")"));
        }
        else {
            $("#product-dialog-header").text("Add Product");
        }
    });
    $("#prompt-dialog-cancel").click(function(){ $("#prompt-dialog").hide("fade"); });
    $("#prompt-dialog-save").click(function(){ deleteNode($("#prompt-dialog").data("node")); });
    $("select").change(function(){
        if($(this).hasClass("has-error") && $(this).val() != ""){
            $(this).removeClass("has-error");
        }
    });
}

function addOptions(id, values){
    var options = $();
    values.forEach(function(value){
        var option = document.createElement('option');
        option.value = value;
        option.text = value;
        options = options.add(option);
    });
    $(id).append(options);
}

function deleteNode(node){
    var object;
    if(node.type == "account"){ object = new SObjectModel.Account(); }
    else if(node.type == "contact"){ object = new SObjectModel.Contact(); }
    else if(node.type == "product"){ object = new SObjectModel.OpportunityLineItem(); }
    if(object != null){
        object.del(node.id, function(error){
            if(error){
                alertify.error(error);
            }
            else{
                var tree = $("#account-hierarchy").jstree(true);
                tree.delete_node(node);
                if($("#prompt-dialog").css("display") != "none") $("#prompt-dialog").hide("fade");
            }
        });
    }
}

function loadNodes(tree, node, cb){
    var account = new SObjectModel.Account();
    var contact = new SObjectModel.Contact();
    var product = new SObjectModel.OpportunityLineItem();

    if(node.id == "#"){
        account.retrieve({
            where: {Id: {eq: window.__APEX_VARS__.PARENT_ACCOUNT_ID}}},
            function(error, accounts){
                if(error){
                    alertify.error(error);
                }
                else{
                    var nodes = [];
                    accounts.forEach(function(record){
                        nodes.push({
                            children: true,
                            id: record.get("Id"),
                            record: record,
                            text: record.get("Name"),
                            type: "account"
                        });
                    });
                    cb.call(tree, nodes);
                }
            });
    }
    else{
        var nodes = [];
        product.retrieve({
            where: {OpportunityId: {eq: window.__APEX_VARS__.OPPORTUNITY_ID},
                    Account__c: {eq: node.id}}},
            function(error, products){
                if(error){
                    alertify.error(error);
                }
                else{
                    products.forEach(function(record){
                        nodes.push({
                            children: false,
                            id: record.get("Id"),
                            product_code: record.get("ProductCode"),
                            record: record,
                            text: record.get("ProductCode") + " (" + record.get("Quantity") + ")",
                            type: "product"
                        });
                    });
                }
            });
        contact.retrieve({
            where: {AccountId: {eq: node.id}}},
            function(error, contacts){
                if(error){
                    alertify.error(error);
                }
                else{
                    contacts.forEach(function(record){
                        var newNode = {
                            children: false,
                            id: record.get("Id"),
                            record: record,
                            text: record.get("FirstName") + " " + record.get("LastName"),
                            type: "contact"
                        };
                        if(record.get("Qualification__c") != undefined && record.get("Qualification__c") != null && record.get("Qualification__c") != "" && record.get("Qualification__c") != "Not Qualified"){
                            newNode["a_attr"] = {
                                class: "qualified-prescriber"
                            }
                        }
                        nodes.push(newNode);
                    });
                }
            });
        account.retrieve({
            where: {ParentId: {eq: node.id}}},
            function(error, accounts){
                if(error){
                    alertify.error(error);
                }
                else{
                    accounts.forEach(function(record){
                        nodes.push({
                            children: true,
                            id: record.get("Id"),
                            record: record,
                            text: record.get("Name"),
                            type: "account"
                        });
                    });
                    cb.call(tree, nodes);
                }
            });
    }
}

function moveNode(data){
    var parentId = data.parent == "#" ? null : data.parent;
    if(data.node.type == "account"){
        var account = new SObjectModel.Account({
            Id: data.node.id,
            ParentId: parentId
        });

        account.update(function(error){
            if(error){
                alertify.error(error);
            }
            else{}
        });
    }
    else if(data.node.type == "contact"){
        var contact = new SObjectModel.Contact({
            Id: data.node.id,
            AccountId: parentId
        });

        contact.update(function(error){
            if(error){
                alertify.error(error);
            }
            else{}
        });
    }
}

function notify(message){
    $("#notification-message").text(message);
    $("#notification").show("fade").delay(5000).hide("fade");
}

function renameNode(data){
    if(data.node.type == "account"){
        var account = new SObjectModel.Account({
            Name: data.text,
            Id: data.node.id
        });

        account.update(function(error){
            if(error){
                alertify.error(error);
            }
            else{
                alertify.success(data.old + ' has been renamed to ' + data.text);
            }
        });
    }
    else if(data.node.type == "contact"){
        var name = data.text.split(" ", 2);
        var contact = new SObjectModel.Contact({
            FirstName: name[0],
            LastName: name[1],
            Id: data.node.id
        });

        contact.update(function(error){
            if(error){
                alertify.error(error);
            }
            else{}
        });
    }
}

function selectInfluence(node){
    var influence = new SObjectModel.AccountContactRole();

    influence.retrieve({
        where: {ContactId: {eq: node.id}}},
        function(error, influences){
            if(error){
                alertify.error(error);
            }
            else{
                var tree = $("#account-hierarchy").jstree(true);
                influences.forEach(function(record){
                    tree.select_node(record.get("AccountId"));
                });
            }
        });
}