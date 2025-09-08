@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendors'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_VENDORS
  as select from zvendors
{
  key id                 as Id,
      company            as Company,
      email              as Email,
      phone              as Phone,
      message            as Message,
      processed          as Processed,
      @Semantics.user.createdBy: true
      localcreatedby     as Localcreatedby,
      @Semantics.systemDateTime.createdAt: true
      localcreatedat     as Localcreatedat,
      @Semantics.user.lastChangedBy: true
      locallastchangedby as Locallastchangedby,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      locallastchangedat as Locallastchangedat,
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat      as Lastchangedat
}
