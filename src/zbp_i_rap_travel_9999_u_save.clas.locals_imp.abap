CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS recalcTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~recalcTotalPrice.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setInitialStatus.

    METHODS calculateTravelID FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~calculateTravelID.

    METHODS validateAgency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateAgency.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD acceptTravel.
  ENDMETHOD.

  METHOD recalcTotalPrice.
  ENDMETHOD.

  METHOD rejectTravel.
  ENDMETHOD.

  METHOD calculateTotalPrice.
  ENDMETHOD.

  METHOD setInitialStatus.
  ENDMETHOD.

  METHOD calculateTravelID.
  ENDMETHOD.

  METHOD validateAgency.
  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateDates.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_RAP_TRAVEL_9999 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_RAP_TRAVEL_9999 IMPLEMENTATION.

  METHOD save_modified.

    data: li_travel type table of zrap_atrav_9999,
          li_upd_travel type table of zrap_atrav_9999,
          li_upd_x_travel type table of zrap_x_atrav_9999,
          li_booking type table of zrap_abook_9999,
          li_upd_booking type table of zrap_abook_9999,
          li_upd_x_booking type table of zrap_x_abook_9999,
          lr_travel_uuid type range of zrap_abook_9999-travel_uuid.


    if create is not initial.
      break ndbs_heri.
      li_upd_travel = CORRESPONDING #( create-travel MAPPING FROM ENTITY ).
      li_upd_booking = CORRESPONDING #( create-booking MAPPING FROM ENTITY ).

*      insert zrap_atrav_9999 from table li_upd_travel.
*      insert zrap_abook_9999 from table li_upd_booking.
    endif.

    if update is not initial.
      break ndbs_heri.
      li_travel = CORRESPONDING #( update-travel mapping from entity ).
      li_upd_x_travel = CORRESPONDING #( update-travel MAPPING FROM ENTITY USING CONTROL ).

      li_booking = CORRESPONDING #( update-booking mapping from entity ).
      li_upd_x_booking = CORRESPONDING #( update-booking mapping from entity using control ).

      select * from zrap_atrav_9999
        for all entries in @li_travel
        where travel_uuid = @li_travel-travel_uuid
        into table @data(li_travels_ori).
      if sy-subrc eq 0.

        li_upd_travel = value #(
          for i = 1 while i le lines( li_travel )
          let control = value #( li_upd_x_travel[ i ] optional )
              travel = value #( li_travel[ i ] optional )
              travel_ori = value #( li_travels_ori[ travel_uuid = travel-travel_uuid ] optional )
          in ( travel_uuid = travel-travel_uuid
               travel_id = travel-travel_id
               agency_id = cond #( when control-agency_id is not initial
                                     then travel-agency_id
                                     else travel_ori-agency_id
                           )
               customer_id = cond #( when control-customer_id is not initial
                                       then travel-customer_id
                                       else travel_ori-customer_id
                           )
               begin_date = cond #( when control-begin_date is not initial
                                      then travel-begin_date
                                      else travel_ori-begin_date
                           )
               end_date = cond #( when control-end_date is not initial
                                    then travel-end_date
                                    else travel_ori-end_date
                           )
               booking_fee = cond #( when control-booking_fee is not initial
                                       then travel-booking_fee
                                       else travel_ori-booking_fee
                           )
               total_price = cond #( when control-total_price is not initial
                                     then travel-total_price
                                     else travel_ori-total_price
                           )
               currency_code = cond #( when control-currency_code is not initial
                                     then travel-currency_code
                                     else travel_ori-currency_code
                           )
               description = cond #( when control-description is not initial
                                     then travel-description
                                     else travel_ori-description
                           )
               overall_status = cond #( when control-overall_status is not initial
                                     then travel-overall_status
                                     else travel_ori-overall_status
                           )
          )
        ).
      else.
        li_upd_travel = li_travel.
      endif.

*      update zrap_atrav_9999 from table li_upd_travel.

    endif.

    if delete is not initial.
      break ndbs_heri.
      lr_travel_uuid = value #(
        for ls_travel in delete-travel
        ( sign = 'I'
          option = 'EQ'
          low = ls_travel-TravelUUID
        )
      ).

*      delete from zrap_atrav_9999 where travel_uuid in lr_travel_uuid.
    endif.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
