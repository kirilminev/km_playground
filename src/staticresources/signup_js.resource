function init(reference_number){
    Visualforce.remoting.Manager.invokeAction("SignupController.getOptions", function(result, event){
        var clinic_specialty_options = $();
        result["clinic_specialty"].forEach(function(specialty){
            var template = $("#checkbox-template div").clone();
            $(template).find(".slds-form-element__label").text(specialty);
            $(template).find("input").attr("id", specialty).data("demographics", result["demographics"][specialty]);
            $(template).find("input").change(function(){
                if($("#specialties-form").find("input:checked").length > 0 && $("[specialty='All']").length == 0) buildDemographics("All", result["demographics"]["All"]);
                if($(this).prop("checked")) buildDemographics(specialty, $(this).data("demographics"));
                displayDemographics();
                if($(this).prop("checked")) $("#specialties-form").find(".slds-checkbox--faux").removeClass("has-error");
            });
            clinic_specialty_options = clinic_specialty_options.add(template);
        });
        $("#specialties-form").append(clinic_specialty_options);
        addOptions("#facility-type", result["facility_type"]);
        addOptions("#provider-specialty", result["provider_specialty"]);
        addOptions("#contact-title", result["title"]);
        addOptions("#provider-title", result["title"]);
        var states = $();
        result["state"].forEach(function(state){
            var option = document.createElement('option');
            option.value = state.split("-")[1];
            option.text = state.split("-")[0];
            states = states.add(option);
        });
        $("#billing-state").append(states);
    }, {escape: false});
    var terms = [
        "Yes, I would like to become a member and receive a free installation of the ContextMedia:Health service for my waiting room at the address listed above.",
        "I understand that the ContextMedia:Health devices and products are provided at no cost.",
        "I understand that ContextMedia:Health is responsible for all maintenance, replacement, and equipment liability for the systems.",
        "I understand that my practice will never be charged fees of any kind to be a member of ContextMedia:Health.",
        "I confirm that the data provided above is accurate for my practice to the best of my knowledge.",
        "I agree to playing the system(s) during all patient hours.",
        "I confirm that the ContextMedia:Health service will be the only TV system in the waiting room and, if applicable, the only tablet and/or digital wallboard in exam room(s).",
        "I agree not to remove, relocate, modify, or disrupt the ContextMedia:Health TV system components, tablets, wallboard, or WiFi without prior consent."
    ];
    var term_options = $();
    terms.forEach(function(term){
        var template = $("#checkbox-template div").clone();
        $(template).find("input").change(function(){
            if($(this).prop("checked")) $(template).find(".slds-checkbox--faux").removeClass("has-error");
        });
        $(template).find(".slds-form-element__label").text(term);
        term_options = term_options.add(template);
    });
    $("#terms-and-conditions").append(term_options);
    
    var wait_times = [
        "1-10 Minutes",
        "11-20 Minutes",
        "21-30 Minutes",
        ">30 Minutes"
    ];
    addOptions(".wait-times", wait_times);
    //event listeners
    $("#add-provider").click(function(){
        $("#provider-dialog").show();
        $("#provider-first-name").focus();
    });
    $("#has-it").change(function(){
        if($("#has-it").val() == "Yes"){
            $("#it-contact-details").show("fade");
        }
        else{
            if($("#it-contact-details").css("display") != "none"){
                $("#it-contact-details").hide("fade");
            }
        }
    });
    $("input:text").change(function(){
        if($(this).hasClass("has-error") && $(this).val() != "") $(this).removeClass("has-error");
    });
    $("#message-dialog-ok").click(function(){
        $("#message-dialog").hide("fade");
    });
    $(".phone-number").change(function(){ formatPhone(this); });
    $("#provider-dialog-cancel").click(function(){
        $("#provider-dialog").hide("fade");
        document.forms["provider-form"].reset();
        $(document.forms["provider-form"].elements).each(function(index, element){
            if($(element).hasClass("has-error")) $(element).removeClass("has-error");
        });
    });
    $("#provider-dialog-save").click(function(){
        addProvider();
    });
    $("#reference-number").change(function(){
        if($("#reference-number").val() != ""){
            var account = new SObjectModel.Account();
            account.retrieve({
                where: {IdGenerator__c: {eq: $("#reference-number").val()}}},
                function(error, accounts){
                    if(error){
                        console.log(error);
                        $("#reference-number").addClass("has-error");
                    }
                    else{
                        if(accounts.length > 0){
                            accounts.forEach(function(record){
                                if(record.get("SignUpFormCompleted__c")){
                                    $("#reference-number").addClass("has-error");
                                }
                                else{
                                    $("input").each(function(index, element){
                                        if($(element).attr("sobject") == "account"){
                                            $(element).val(record.get($(element).attr("fieldname")));
                                            if($(element).hasClass("has-error")) $(element).removeClass("has-error");
                                        }
                                    });
                                    $("select").each(function(index, element){
                                        if($(element).attr("sobject") == "account"){
                                            $(element).val(record.get($(element).attr("fieldname")));
                                            if($(element).hasClass("has-error")) $(element).removeClass("has-error");
                                        }
                                    });
                                    if(record.get("Network__c") != null) {
                                        record.get("Network__c").split(";").forEach(function(specialty){
                                            $(specialty).prop("checked", "true");
                                        });
                                    }
                                    $("#reference-number").data("account_id", record.get("Id"));
                                    $("#reference-number").addClass("has-success");
                                }
                            });
                        }
                        else{
                            if($("#reference-number").hasClass("has-error")) $("#reference-number").removeClass("has-error");
                            $("#reference-number").addClass("has-error");
                        }
                    }
                });
        }
        else{
            if($("#reference-number").hasClass("has-error")) $("#reference-number").removeClass("has-error");
            if($("#reference-number").hasClass("has-success")) $("#reference-number").removeClass("has-success");
        }
    });
    $("select").change(function(){
        if($(this).hasClass("has-error") && $(this).val() != "") $(this).removeClass("has-error");
    });
    $("#submit").click(function(){save(false);});
    $("#submit-and-new").click(function(){save(true);});

    $("#reference-number").val(reference_number).change();
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

function addProvider(){
    var errors = [];
    $(document.forms["provider-form"].elements).each(function(index, element){
        if($(element).prop("required") && ($(element).val() == "" || $(element).val() == "--")){
            errors.push(element);
        }
    });
    if(errors.length > 0){
        $(errors).addClass("has-error");
    }
    else{
        var provider = {
            first_name : $("#provider-first-name").val(),
            last_name : $("#provider-last-name").val(),
            title : $("#provider-title").val(),
            specialty : $("#provider-specialty").val()
        };
        var provider_row = $("#provider-template").clone();
        provider_row.data("provider", provider);
        $(provider_row).children().each(function(index, child){
            if($(child).attr("data-label") == "Name"){ $(child).text(provider.first_name + " " + provider.last_name); }
            else if($(child).attr("data-label") == "Title"){ $(child).text(provider.title); }
            else if($(child).attr("data-label") == "Specialty"){ $(child).text(provider.specialty); }
        });
        $(provider_row).find("button").click(function(){
            $(provider_row).hide("fade", function(){
                $(provider_row).remove();
                if($("#provider-table-body").children().length == 1) $("#provider-table").slideUp();
            });
        });
        $("#provider-table-body").append(provider_row);
        if($("#provider-table").css("display") == "none") $("#provider-table").show("fade");
        $(provider_row).show("fade");

        $("#provider-dialog").hide("fade");
        document.forms["provider-form"].reset();
        $("#add-provider").focus();
    }
}

function buildDemographics(specialty, demographics){
    if(demographics != null){
        demographics.forEach(function(demographic){
            var template = $("#demographic-template").clone();
            $(template).attr("specialty", specialty);
            $(template).find("label").text(demographic.label);
            $(template).find("select").attr("fieldname", demographic.name);
            $("#demographics").append(template);
            addOptions($(template).find("select"), demographic.options);
        });
    }
}

function displayDemographics(){
    var selected_specialties = [];
    $("#specialties-form").find("input").each(function(index, element){
        if($(element).prop("checked")){
            $("[specialty='" + element.id + "']").show("fade");
            selected_specialties.push(element.id);
        }
        else{
            $("[specialty='" + element.id + "']").hide("fade", function(){
                $(this).remove();
            });
        }
    });
    if(selected_specialties.length > 0) $("[specialty='All']").show("fade");
    else $("[specialty='All']").hide("fade", function(){
        $(this).remove();
    });
}

function formatPhone(a) {
    a.value = a.value.trim();  
    var b = a.value,
    c = "",  
    d = -1;  
    if (0 < b.length && "+" != b.charAt(0)){  
        var e = 0;  
        if("1" == b.charAt(0)){
          b = b.substring(1, b.length);  
        }
        for(i = 0; i < b.length; i++){  
            var f = b.charAt(i);  
            if(f >= "0" && f <= "9"){  
                if(e == 0) c += "(";  
                else if(e == 3) c += ") ";  
                else if(e == 6) c += "-";  
                c += f;  
                e++; 
            }  
            if(!(f >= "0" && f <= "9") && f != " " && f != "-" && f != "." && f != "(" && f != ")"){  
                d = i;  
                break; 
            }  
        }  
        if(d >= 0) c += " " + b.substring(d, b.length);  
        if(e == 10 && c.length <= 40) a.value = c;
    }  
    return true;
}

function save(and_new){
    var account = new SObjectModel.Account();
    var contact = new SObjectModel.Contact();
    var errors = [];
    var providers = [];
    var selected_specialties = [];

    $(document.forms["clinic-form"].elements).each(function(index, element){
        if($(element).prop("required")) {
            if ($(element).is("input") && $(element).val() == "") errors.push(element);
            else if($(element).is("select") && $(element).val() == "--") errors.push(element);
        }
    });
    $("#provider-table-body").children().each(function(index, provider_row){
        if($(provider_row).data("provider") != null){
            providers.push($(provider_row).data("provider"));
        }
    });
    if(providers.length == 0){
        errors.push(providers);
    }
    $("#specialties-form").find("input").each(function(index, element){
        if($(element).prop("checked")) selected_specialties.push(element.id);
    });
    if(selected_specialties.length == 0){
        $("#specialties-form").find(".slds-checkbox--faux").addClass("has-error");
        errors.push(selected_specialties);
    }
    $("#terms-and-conditions").find("input").each(function(index, element){
        if(!$(element).prop("checked")){
            errors.push(element);
            $(element).siblings(".slds-checkbox--faux").addClass("has-error");
        }
    });

    if(errors.length > 0){
        console.log(errors);
        $(errors).addClass("has-error");
        $("#message-dialog").find("p").text("Please ensure that you have filled out all required fields, highlighted in red, and added at least one provider before submitting again.");
        $("#message-dialog").show();
    }
    else {
        account.set("SignUpFormCompleted__c", true);
        if($("#reference-number").data("account_id") != null) account.set("Id", $("#reference-number").data("account_id"));
        $(document.forms["clinic-form"].elements).each(function(index, element){
            if($(element).attr("sobject") == "account" && $(element).attr("fieldname") != null){
                if(element.type == "checkbox") account.set($(element).attr("fieldname"), $(element).prop("checked"));
                else{
                    if($(element).attr("fieldname") == "BillingStreet") account.set($(element).attr("fieldname"), $(element).val() + " \r\n " + $("#billing-street-2").val());
                    else account.set($(element).attr("fieldname"), $(element).val());
                }
            }
            else if($(element).attr("sobject") == "contact" && $(element).attr("fieldname") != null){
                if(element.type == "checkbox") contact.set($(element).attr("fieldname"), $(element).prop("checked"));
                else contact.set($(element).attr("fieldname"), $(element).val());
            }
        });
        var content_requested = "";
        selected_specialties.forEach(function(specialty){
            if(content_requested == "") content_requested = specialty;
            else content_requested += ";" + specialty;
        });
        account.set("Network__c", content_requested);
        console.log(account);
        console.log(contact);
        console.log(providers);
        
        Visualforce.remoting.Manager.invokeAction("SignupController.save", account._props, contact._props, providers, function(result, event){
            if(result=="Success!"){
                if(and_new){
                    window.location.reload();
                }
                else{
                    window.location.href = "http://www.contextmediahealth.com/congratulations/";
                }
            }
            else{
                $("#message-dialog").find("p").text("There was an error submitting this form. Please contact your Healthcare Sales Executive and reference the following error message: " + result);
                $("#message-dialog").show();
            }
        });
    }
}