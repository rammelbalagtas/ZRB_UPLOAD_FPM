@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendors'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_VENDORS_UPLOAD
  provider contract transactional_query
  as projection on ZI_VENDORS
{
  key Id,
      Company,
      Email,
      Phone,
      Message,
      Processed,
      Localcreatedby,
      Localcreatedat,
      Locallastchangedby,
      Locallastchangedat,
      Lastchangedat
}
