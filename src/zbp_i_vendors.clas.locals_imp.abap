CLASS lhc_ZI_VENDORS DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Vendors RESULT result.
    METHODS uploadfile1 FOR MODIFY
      IMPORTING keys FOR ACTION vendors~uploadfile1.

    METHODS uploadfile2 FOR MODIFY
      IMPORTING keys FOR ACTION vendors~uploadfile2 RESULT result.
    METHODS processall FOR MODIFY
      IMPORTING keys FOR ACTION vendors~processall.
    METHODS deletepreviousrecords FOR MODIFY
      IMPORTING keys FOR ACTION vendors~deletepreviousrecords.

ENDCLASS.

CLASS lhc_ZI_VENDORS IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD uploadFile1.
    TYPES: BEGIN OF ty_excel,
             id      TYPE string,
             company TYPE string,
             email   TYPE string,
             phone   TYPE string,
           END OF ty_excel,
           tt_row TYPE STANDARD TABLE OF ty_excel.

    DATA lt_rows TYPE tt_row.
    DATA lt_content TYPE STANDARD TABLE OF zfilecontent.
    DATA ls_content LIKE LINE OF lt_content.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<fs_key>) INDEX 1.
    IF sy-subrc EQ 0.
      DATA(lv_content) = <fs_key>-%param-Attachment.
      IF lv_content IS NOT INITIAL.
        DATA(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_content )->read_access( ).
        DATA(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

        DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

        DATA(lo_execute) = lo_worksheet->select( lo_selection_pattern
          )->row_stream(
          )->operation->write_to( REF #( lt_rows ) ).

        lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
                   )->if_xco_xlsx_ra_operation~execute( ).
      ENDIF.
    ENDIF.

    DATA lt_data TYPE TABLE FOR CREATE zi_vendors.
    lt_data =  VALUE #( FOR ls_row IN lt_rows (
                                                                                %is_draft = '00'
                                                                                id = ls_row-id
                                                                                company = ls_row-company
                                                                                email = ls_row-email
                                                                                phone = ls_row-phone
                                                                                %control = VALUE #( id   = if_abap_behv=>mk-on
                                                                                                    company    = if_abap_behv=>mk-on
                                                                                                    phone    = if_abap_behv=>mk-on
                                                                                                    email    = if_abap_behv=>mk-on
                                                                                                    message = if_abap_behv=>mk-on
                                                                                                    processed = if_abap_behv=>mk-on ) ) ).
*    SELECT * FROM
    TYPES: BEGIN OF ts_my_entity_key,
             id TYPE string,
           END OF ts_my_entity_key.

    TYPES: tt_my_entity_keys TYPE STANDARD TABLE OF ts_my_entity_key WITH EMPTY KEY.

    DATA: lt_keys_draft   TYPE tt_my_entity_keys.
    DATA: lt_keys_active  TYPE tt_my_entity_keys.

    " Populate lt_keys with the keys of the records you want to read
    SELECT id FROM zvendorsd INTO TABLE @lt_keys_draft.
    SELECT id FROM zvendors INTO TABLE @lt_keys_active.

    " Read all records for the specified entity
    READ ENTITIES OF zi_vendors IN LOCAL MODE
            ENTITY Vendors
            ALL FIELDS
            WITH VALUE #( FOR ls_key IN lt_keys_draft ( %is_draft = '01'
                                                        %key-Id = ls_key-id ) )
            RESULT DATA(lt_vendor_draft).

    "Discard draft entities
    IF lt_vendor_draft IS NOT INITIAL.
      MODIFY ENTITIES OF zi_vendors IN LOCAL MODE
        ENTITY Vendors
          EXECUTE Discard FROM
          VALUE #( FOR ls_vendor_draft IN lt_vendor_draft (  %key-Id = ls_vendor_draft-id ) )
        REPORTED DATA(discard_reported)
        FAILED DATA(discard_failed)
        MAPPED DATA(discard_mapped).
    ENDIF.

    READ ENTITIES OF zi_vendors IN LOCAL MODE
            ENTITY Vendors
            ALL FIELDS
            WITH VALUE #( FOR ls_key IN lt_keys_active ( %is_draft = '00'
                                                        %key-Id = ls_key-id ) )
            RESULT DATA(lt_vendor_active).

    "Delete active entities
    MODIFY ENTITIES OF zi_vendors IN LOCAL MODE
    ENTITY Vendors
    DELETE FROM VALUE #( FOR ls_vendor_active IN lt_vendor_active (  "%is_draft = ls_vendor_active-%is_draft
                                                                     %key-Id   = ls_vendor_active-id ) )
    MAPPED DATA(lt_mapped_delete)
    REPORTED DATA(lt_reported_delete)
    FAILED DATA(lt_failed_delete).

    MODIFY ENTITIES OF zi_vendors IN LOCAL MODE
        ENTITY Vendors
        CREATE AUTO FILL CID FIELDS ( id company email phone message processed ) WITH lt_data
        MAPPED DATA(lt_mapped_create)
        REPORTED DATA(lt_reported_create)
        FAILED DATA(lt_failed_create).

*
*    mapped-vendors = lt_mapped_create-vendors.
*    failed-vendors = lt_failed_create-vendors.
*    reported-vendors = lt_reported_create-vendors.

*    LOOP AT lt_data INTO DATA(ls_data).
*      APPEND VALUE #( id = ls_data-id
*                      %is_draft = '01'
*                      %create = '01'
*                      %action-uploadfile1 = '01' ) TO failed-vendors.
*      APPEND VALUE #( id = ls_data-id
*                      %is_draft = '01'
*                      %create = '01'
*                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                        text = 'Fill up mandatory fields' )
*                      %element-email   = if_abap_behv=>mk-on
*                    ) TO reported-vendors.
*    ENDLOOP.

  ENDMETHOD.

  METHOD uploadFile2.
    TYPES: BEGIN OF ty_excel,
             id      TYPE string,
             company TYPE string,
             email   TYPE string,
             phone   TYPE string,
           END OF ty_excel,
           tt_row TYPE STANDARD TABLE OF ty_excel.

    DATA lt_rows TYPE tt_row.
    DATA lt_content TYPE STANDARD TABLE OF zfilecontent.
    DATA ls_content LIKE LINE OF lt_content.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<fs_key>) INDEX 1.
    IF sy-subrc EQ 0.
      DATA(lv_content) = <fs_key>-%param-Attachment.
      IF lv_content IS NOT INITIAL.
        DATA(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_content )->read_access( ).
        DATA(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

        DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

        DATA(lo_execute) = lo_worksheet->select( lo_selection_pattern
          )->row_stream(
          )->operation->write_to( REF #( lt_rows ) ).

        lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
                   )->if_xco_xlsx_ra_operation~execute( ).
      ENDIF.
    ENDIF.

    DATA lt_data TYPE TABLE FOR CREATE zi_vendors.
    lt_data =  VALUE #( FOR ls_row IN lt_rows (
                                                                                %is_draft = '01'
                                                                                id = ls_row-id
                                                                                company = ls_row-company
                                                                                email = ls_row-email
                                                                                phone = ls_row-phone
*                                                                                %cid = ls_row-Material
                                                                                %control = VALUE #( id   = if_abap_behv=>mk-on
                                                                                                    company    = if_abap_behv=>mk-on
                                                                                                    phone    = if_abap_behv=>mk-on
                                                                                                    email    = if_abap_behv=>mk-on ) ) ).
*    SELECT * FROM
    TYPES: BEGIN OF ts_my_entity_key,
             id TYPE string,
           END OF ts_my_entity_key.

    TYPES: tt_my_entity_keys TYPE STANDARD TABLE OF ts_my_entity_key WITH EMPTY KEY.

    DATA: lt_keys_draft   TYPE tt_my_entity_keys.
    DATA: lt_keys_active  TYPE tt_my_entity_keys.

    " Populate lt_keys with the keys of the records you want to read
    SELECT id FROM zvendorsd INTO TABLE @lt_keys_draft.
    SELECT id FROM zvendors INTO TABLE @lt_keys_active.

*    " Read all records for the specified entity
*    READ ENTITIES OF zi_vendors IN LOCAL MODE
*            ENTITY Vendors
*            ALL FIELDS
*            WITH VALUE #( FOR ls_key IN lt_keys_draft ( %is_draft = '01'
*                                                        %key-Id = ls_key-id ) )
*            RESULT DATA(lt_vendor_draft).
*
*    "Discard draft entities
*    IF lt_vendor_draft IS NOT INITIAL.
*      MODIFY ENTITIES OF zi_vendors IN LOCAL MODE
*        ENTITY Vendors
*          EXECUTE Discard FROM
*          VALUE #( FOR ls_vendor_draft IN lt_vendor_draft (  %key-Id = ls_vendor_draft-id ) )
*        REPORTED DATA(discard_reported)
*        FAILED DATA(discard_failed)
*        MAPPED DATA(discard_mapped).
*    ENDIF.

    READ ENTITIES OF zi_vendors IN LOCAL MODE
            ENTITY Vendors
            ALL FIELDS
            WITH VALUE #( FOR ls_key IN lt_keys_active ( %is_draft = '00'
                                                        %key-Id = ls_key-id ) )
            RESULT DATA(lt_vendor_active).

    "Delete active entities
    MODIFY ENTITIES OF zi_vendors IN LOCAL MODE
    ENTITY Vendors
    DELETE FROM VALUE #( FOR ls_vendor_active IN lt_vendor_active (  "%is_draft = ls_vendor_active-%is_draft
                                                                     %key-Id   = ls_vendor_active-id ) )
    MAPPED DATA(lt_mapped_delete)
    REPORTED DATA(lt_reported_delete)
    FAILED DATA(lt_failed_delete).

    MODIFY ENTITIES OF zi_vendors IN LOCAL MODE
        ENTITY Vendors
        CREATE AUTO FILL CID FIELDS ( id company email phone message processed ) WITH lt_data
        MAPPED DATA(lt_mapped_create)
        REPORTED DATA(lt_reported_create)
        FAILED DATA(lt_failed_create).

    mapped-vendors = lt_mapped_create-vendors.
    failed-vendors = lt_failed_create-vendors.
    reported-vendors = lt_reported_create-vendors.

    RETURN.
*    APPEND VALUE #( %tky = ls_header-%tky ) TO failed-header.
*    APPEND VALUE #( %tky = ls_header-%tky
*                    %state_area         = 'VALIDATE_ONSAVE'
*                    %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                      text = 'Fill up mandatory fields' )
*
*                    %element-validto   = if_abap_behv=>mk-on
*                   ) TO reported-header.

*    " Populate lt_keys with the keys of the records you want to read
*    SELECT id FROM zvendorsd INTO TABLE @lt_keys.
*
*    " Read all records for the specified entity
*    READ ENTITIES OF zi_vendors IN LOCAL MODE
*            ENTITY Vendors
*            ALL FIELDS
*            WITH VALUE #( FOR ls_key IN lt_keys ( %is_draft = '01'
*                                                  %key-Id = ls_key-id ) )
*            RESULT lt_vendor.
*
*    result = VALUE #( FOR vendor IN lt_vendor
*                          ( %cid = <fs_key>-%cid
*                            %param = vendor ) ).

  ENDMETHOD.

  METHOD processAll.
    TYPES: BEGIN OF ts_my_entity_key,
             id TYPE string,
           END OF ts_my_entity_key.

    TYPES: tt_my_entity_keys TYPE STANDARD TABLE OF ts_my_entity_key WITH EMPTY KEY.

    DATA: lt_keys   TYPE tt_my_entity_keys.
    DATA: lt_keys_active  TYPE tt_my_entity_keys.

    " Populate lt_keys with the keys of the records you want to read
    SELECT id FROM zvendors INTO TABLE @lt_keys.

    " Read all records for the specified entity
    READ ENTITIES OF zi_vendors IN LOCAL MODE
            ENTITY Vendors
            ALL FIELDS
            WITH VALUE #( FOR ls_key IN lt_keys ( %is_draft = '00'
                                                   %key-Id = ls_key-id ) )
            RESULT DATA(lt_vendor).

    MODIFY ENTITIES OF zi_vendors IN LOCAL MODE
        ENTITY Vendors
        UPDATE FIELDS ( Processed )
        WITH VALUE #( FOR ls_vendor IN lt_vendor
                               ( %is_draft = if_abap_behv=>mk-off
                                 id        = ls_vendor-id
                                 Processed = 'X'
                                 %control-Processed = if_abap_behv=>mk-on ) )
           MAPPED DATA(upd_mapped)
           FAILED DATA(upd_failed)
           REPORTED DATA(upd_reported).

*    " Populate lt_keys with the keys of the records you want to read
*    SELECT id FROM zvendors INTO TABLE @lt_keys.
*
*    " Read all records for the specified entity
*    READ ENTITIES OF zi_vendors IN LOCAL MODE
*            ENTITY Vendors
*            ALL FIELDS
*            WITH VALUE #( FOR ls_key IN lt_keys ( %is_draft = '00'
*                                                  %key-Id = ls_key-id ) )
*            RESULT lt_vendor.
*
*    READ TABLE keys ASSIGNING FIELD-SYMBOL(<fs_key>) INDEX 1.
*    result = VALUE #( FOR vendor IN lt_vendor (  %cid = <fs_key>-%cid
*                                                %param = vendor ) ).

  ENDMETHOD.

  METHOD deletePreviousRecords.

    TYPES: BEGIN OF ts_my_entity_key,
             id TYPE string,
           END OF ts_my_entity_key.

    TYPES: tt_my_entity_keys TYPE STANDARD TABLE OF ts_my_entity_key WITH EMPTY KEY.

    DATA: lt_keys_draft   TYPE tt_my_entity_keys.
    DATA: lt_keys_active  TYPE tt_my_entity_keys.

    " Populate lt_keys with the keys of the records you want to read
    SELECT id FROM zvendors INTO TABLE @lt_keys_active.

    READ ENTITIES OF zi_vendors IN LOCAL MODE
            ENTITY Vendors
            ALL FIELDS
            WITH VALUE #( FOR ls_key IN lt_keys_active ( %is_draft = '00'
                                                        %key-Id = ls_key-id ) )
            RESULT DATA(lt_vendor_active).

    "Delete active entities
    MODIFY ENTITIES OF zi_vendors IN LOCAL MODE
    ENTITY Vendors
    DELETE FROM VALUE #( FOR ls_vendor_active IN lt_vendor_active (  "%is_draft = ls_vendor_active-%is_draft
                                                                     %key-Id   = ls_vendor_active-id ) )
    MAPPED DATA(lt_mapped_delete)
    REPORTED DATA(lt_reported_delete)
    FAILED DATA(lt_failed_delete).

  ENDMETHOD.

ENDCLASS.
