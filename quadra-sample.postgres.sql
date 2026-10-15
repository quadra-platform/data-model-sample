CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS fund;
CREATE SCHEMA IF NOT EXISTS mdm;
CREATE SCHEMA IF NOT EXISTS pm;
CREATE SCHEMA IF NOT EXISTS ref;

-- Registry of data sources for reference data, market data, and regulatory filings
CREATE TABLE ref.source (
  source_code text NOT NULL PRIMARY KEY, -- Source identifier: BLOOMBERG, REFINITIV, ECB, OANDA, NPORT, INTERNAL, MANUAL
  source_name text NOT NULL, -- Display name for the source
  source_type text NOT NULL,
  description text NULL, -- Description of what this source provides
  priority smallint NOT NULL DEFAULT 100 CHECK (priority >= 0), -- Source priority (lower wins; 0 = override, 100 = default).
  is_system boolean NOT NULL DEFAULT FALSE, -- Whether this record is system-provided (shipped with Quadra) or organization-specific
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this source is currently active
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE ref.source IS 'Registry of data sources for reference data, market data, and regulatory filings';
COMMENT ON COLUMN ref.source.source_code IS 'Source identifier: BLOOMBERG, REFINITIV, ECB, OANDA, NPORT, INTERNAL, MANUAL';
COMMENT ON COLUMN ref.source.source_name IS 'Display name for the source';
COMMENT ON COLUMN ref.source.description IS 'Description of what this source provides';
COMMENT ON COLUMN ref.source.priority IS 'Source priority (lower wins; 0 = override, 100 = default).';
COMMENT ON COLUMN ref.source.is_system IS 'Whether this record is system-provided (shipped with Quadra) or organization-specific';
COMMENT ON COLUMN ref.source.is_active IS 'Whether this source is currently active';

-- ISO 4217 currency reference table using currency codes as primary keys
CREATE TABLE ref.currency (
  currency_code character varying(3) NOT NULL PRIMARY KEY, -- ISO 4217 3-letter currency code (USD, EUR, GBP)
  name text NOT NULL, -- Official currency name (e.g., "United States Dollar")
  short_name text NULL, -- Short display name for UI (e.g., "US Dollar")
  numeric_code integer NULL, -- ISO 4217 3-digit numeric code (e.g., 840 for USD) - used for legacy system integration and SWIFT
  minor_units integer NULL, -- Number of decimal places (2 for USD/EUR, 0 for JPY, 3 for BHD) - critical for rounding and display
  symbol text NULL, -- Currency symbol for display (e.g., "$", "€", "£") - note: symbols can be ambiguous across currencies
  is_system boolean NOT NULL DEFAULT FALSE, -- Whether this record is system-provided (shipped with Quadra) or organization-specific
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this currency is currently active
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE ref.currency IS 'ISO 4217 currency reference table using currency codes as primary keys';
COMMENT ON COLUMN ref.currency.currency_code IS 'ISO 4217 3-letter currency code (USD, EUR, GBP)';
COMMENT ON COLUMN ref.currency.name IS 'Official currency name (e.g., "United States Dollar")';
COMMENT ON COLUMN ref.currency.short_name IS 'Short display name for UI (e.g., "US Dollar")';
COMMENT ON COLUMN ref.currency.numeric_code IS 'ISO 4217 3-digit numeric code (e.g., 840 for USD) - used for legacy system integration and SWIFT';
COMMENT ON COLUMN ref.currency.minor_units IS 'Number of decimal places (2 for USD/EUR, 0 for JPY, 3 for BHD) - critical for rounding and display';
COMMENT ON COLUMN ref.currency.symbol IS 'Currency symbol for display (e.g., "$", "€", "£") - note: symbols can be ambiguous across currencies';
COMMENT ON COLUMN ref.currency.is_system IS 'Whether this record is system-provided (shipped with Quadra) or organization-specific';
COMMENT ON COLUMN ref.currency.is_active IS 'Whether this currency is currently active';

-- ISO 3166-1 country reference table using alpha-2 codes as primary keys
CREATE TABLE ref.country (
  country_code character varying(2) NOT NULL PRIMARY KEY, -- ISO 3166-1 alpha-2 country code (US, GB, DE, JP, etc.)
  name text NOT NULL, -- Official country name (e.g., "United States of America")
  short_name text NULL, -- Short display name for UI (e.g., "USA", "UK")
  alpha_3_code character varying(3) NULL, -- ISO 3166-1 alpha-3 country code (USA, GBR, DEU, JPN)
  numeric_code character varying(3) NULL, -- ISO 3166-1 numeric code (840, 826, 276, 392)
  region text NULL, -- Geographic region: AMERICAS, EUROPE, ASIA, AFRICA, OCEANIA, ANTARCTICA
  sub_region text NULL, -- Geographic sub-region: NORTHERN_AMERICA, WESTERN_EUROPE, EASTERN_ASIA, etc.
  regulatory_region text NULL, -- Regulatory grouping: EU, EEA, FATF, OECD, etc.
  is_sovereign boolean NULL, -- Whether this is a sovereign nation (false for territories, dependencies)
  sovereignty_country_code character varying(2) NULL, -- For territories: reference to sovereign country
  is_system boolean NOT NULL DEFAULT FALSE, -- Whether this record is system-provided (shipped with Quadra) or organization-specific
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this country is currently active
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE ref.country IS 'ISO 3166-1 country reference table using alpha-2 codes as primary keys';
COMMENT ON COLUMN ref.country.country_code IS 'ISO 3166-1 alpha-2 country code (US, GB, DE, JP, etc.)';
COMMENT ON COLUMN ref.country.name IS 'Official country name (e.g., "United States of America")';
COMMENT ON COLUMN ref.country.short_name IS 'Short display name for UI (e.g., "USA", "UK")';
COMMENT ON COLUMN ref.country.alpha_3_code IS 'ISO 3166-1 alpha-3 country code (USA, GBR, DEU, JPN)';
COMMENT ON COLUMN ref.country.numeric_code IS 'ISO 3166-1 numeric code (840, 826, 276, 392)';
COMMENT ON COLUMN ref.country.region IS 'Geographic region: AMERICAS, EUROPE, ASIA, AFRICA, OCEANIA, ANTARCTICA';
COMMENT ON COLUMN ref.country.sub_region IS 'Geographic sub-region: NORTHERN_AMERICA, WESTERN_EUROPE, EASTERN_ASIA, etc.';
COMMENT ON COLUMN ref.country.regulatory_region IS 'Regulatory grouping: EU, EEA, FATF, OECD, etc.';
COMMENT ON COLUMN ref.country.is_sovereign IS 'Whether this is a sovereign nation (false for territories, dependencies)';
COMMENT ON COLUMN ref.country.sovereignty_country_code IS 'For territories: reference to sovereign country';
COMMENT ON COLUMN ref.country.is_system IS 'Whether this record is system-provided (shipped with Quadra) or organization-specific';
COMMENT ON COLUMN ref.country.is_active IS 'Whether this country is currently active';

-- Exchange and trading venue reference table using exchange codes as primary keys
CREATE TABLE ref.exchange (
  exchange_code text NOT NULL PRIMARY KEY, -- Exchange identifier: NYSE, NASDAQ, LSE, XLON, XPAR, etc. (use MIC codes where possible)
  name text NOT NULL, -- Official exchange name (e.g., "New York Stock Exchange")
  short_name text NULL, -- Short display name for UI (e.g., "NYSE")
  mic_code character varying(4) NULL, -- ISO 10383 Market Identifier Code (4-character code)
  country_code character varying(2) NULL, -- Country where exchange is located
  city text NULL, -- City where exchange is located
  timezone text NULL, -- IANA timezone (e.g., "America/New_York", "Europe/London")
  currency_code character varying(3) NULL, -- Primary trading currency for the exchange
  exchange_type text NULL,
  operating_hours text NULL, -- Trading hours in local time (e.g., "09:30-16:00")
  settlement_cycle_days integer NULL, -- Default settlement cycle: T+2, T+1, T+0
  website_url text NULL, -- Official website URL
  is_system boolean NOT NULL DEFAULT FALSE, -- Whether this record is system-provided (shipped with Quadra) or organization-specific
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this exchange is currently active
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE ref.exchange IS 'Exchange and trading venue reference table using exchange codes as primary keys';
COMMENT ON COLUMN ref.exchange.exchange_code IS 'Exchange identifier: NYSE, NASDAQ, LSE, XLON, XPAR, etc. (use MIC codes where possible)';
COMMENT ON COLUMN ref.exchange.name IS 'Official exchange name (e.g., "New York Stock Exchange")';
COMMENT ON COLUMN ref.exchange.short_name IS 'Short display name for UI (e.g., "NYSE")';
COMMENT ON COLUMN ref.exchange.mic_code IS 'ISO 10383 Market Identifier Code (4-character code)';
COMMENT ON COLUMN ref.exchange.country_code IS 'Country where exchange is located';
COMMENT ON COLUMN ref.exchange.city IS 'City where exchange is located';
COMMENT ON COLUMN ref.exchange.timezone IS 'IANA timezone (e.g., "America/New_York", "Europe/London")';
COMMENT ON COLUMN ref.exchange.currency_code IS 'Primary trading currency for the exchange';
COMMENT ON COLUMN ref.exchange.operating_hours IS 'Trading hours in local time (e.g., "09:30-16:00")';
COMMENT ON COLUMN ref.exchange.settlement_cycle_days IS 'Default settlement cycle: T+2, T+1, T+0';
COMMENT ON COLUMN ref.exchange.website_url IS 'Official website URL';
COMMENT ON COLUMN ref.exchange.is_system IS 'Whether this record is system-provided (shipped with Quadra) or organization-specific';
COMMENT ON COLUMN ref.exchange.is_active IS 'Whether this exchange is currently active';

-- Security issuers - legal entities that issue financial instruments
CREATE TABLE core.issuer (
  issuer_id bigint NOT NULL PRIMARY KEY, -- Master identity issued by mdm.master_key (MDM-managed).
  issuer_code text NOT NULL UNIQUE, -- Business code (LEI, ticker, or composite key)
  legal_name text NOT NULL, -- Official issuer legal name
  short_name text NULL, -- Short/display name
  lei_code character varying(20) NULL CHECK ((lei_code IS NULL OR length(lei_code::text) = 20 AND lei_code::text ~ '^[A-Z0-9]{20}$'::text)), -- Legal Entity Identifier
  cusip_root character varying(6) NULL CHECK ((cusip_root IS NULL OR length(cusip_root::text) = 6 AND cusip_root::text ~ '^[A-Z0-9]{6}$'::text)), -- CUSIP 6-character issuer identifier (first 6 characters of CUSIP)
  country_of_domicile character varying(2) NULL, -- ISO 3166-1 alpha-2 country code
  country_of_incorporation character varying(2) NULL, -- For legal entities: country of incorporation
  issuer_type text NOT NULL,
  organization_type text NULL,
  credit_rating text NULL, -- Issuer credit rating
  is_sovereign boolean NULL DEFAULT FALSE, -- Government/sovereign issuer flag
  compliance_status text NULL,
  issuer_external_identifiers jsonb NULL DEFAULT '{}'::jsonb, -- Additional external IDs
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this issuer is currently active
  is_deleted boolean NOT NULL DEFAULT FALSE CHECK (is_deleted = false OR is_active = false), -- Logical deletion flag for issuer records
  issuer_attributes jsonb NULL DEFAULT '{}'::jsonb, -- Flexible attributes for issuer-specific data
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE core.issuer IS 'Security issuers - legal entities that issue financial instruments';
COMMENT ON COLUMN core.issuer.issuer_id IS 'Master identity issued by mdm.master_key (MDM-managed).';
COMMENT ON COLUMN core.issuer.issuer_code IS 'Business code (LEI, ticker, or composite key)';
COMMENT ON COLUMN core.issuer.legal_name IS 'Official issuer legal name';
COMMENT ON COLUMN core.issuer.short_name IS 'Short/display name';
COMMENT ON COLUMN core.issuer.lei_code IS 'Legal Entity Identifier';
COMMENT ON COLUMN core.issuer.cusip_root IS 'CUSIP 6-character issuer identifier (first 6 characters of CUSIP)';
COMMENT ON COLUMN core.issuer.country_of_domicile IS 'ISO 3166-1 alpha-2 country code';
COMMENT ON COLUMN core.issuer.country_of_incorporation IS 'For legal entities: country of incorporation';
COMMENT ON COLUMN core.issuer.credit_rating IS 'Issuer credit rating';
COMMENT ON COLUMN core.issuer.is_sovereign IS 'Government/sovereign issuer flag';
COMMENT ON COLUMN core.issuer.issuer_external_identifiers IS 'Additional external IDs';
COMMENT ON COLUMN core.issuer.is_active IS 'Whether this issuer is currently active';
COMMENT ON COLUMN core.issuer.is_deleted IS 'Logical deletion flag for issuer records';
COMMENT ON COLUMN core.issuer.issuer_attributes IS 'Flexible attributes for issuer-specific data';

-- Position valuation type reference table - defines different contexts for position valuations (EOD, intraday, NAV, etc.)
CREATE TABLE ref.position_type (
  position_type_code text NOT NULL PRIMARY KEY, -- Position type: EOD, INTRADAY, PRELIM, FINAL, NAV_CALC, TRADING_BOOK
  name text NOT NULL, -- Display name for the position type
  description text NULL, -- Detailed explanation of when this position type is used
  valuation_method text NULL, -- Valuation approach: MARKET_PRICE, MODEL, VENDOR, MANUAL
  reporting_priority integer NULL, -- Priority for reporting (lower number = higher priority) - determines which valuation is used when multiple exist
  is_official_valuation boolean NULL DEFAULT FALSE, -- Whether this is a official book of record valuation for regulatory/accounting purposes
  frequency text NULL, -- How often positions of this type are updated: DAILY, INTRADAY, WEEKLY, MONTHLY
  business_day_offset integer NULL, -- Business day offset for this position type (0=same day, -1=previous day, +1=next day)
  is_system boolean NOT NULL DEFAULT FALSE, -- Whether this record is system-provided (shipped with Quadra) or organization-specific
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this position type is currently active
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE ref.position_type IS 'Position valuation type reference table - defines different contexts for position valuations (EOD, intraday, NAV, etc.)';
COMMENT ON COLUMN ref.position_type.position_type_code IS 'Position type: EOD, INTRADAY, PRELIM, FINAL, NAV_CALC, TRADING_BOOK';
COMMENT ON COLUMN ref.position_type.name IS 'Display name for the position type';
COMMENT ON COLUMN ref.position_type.description IS 'Detailed explanation of when this position type is used';
COMMENT ON COLUMN ref.position_type.valuation_method IS 'Valuation approach: MARKET_PRICE, MODEL, VENDOR, MANUAL';
COMMENT ON COLUMN ref.position_type.reporting_priority IS 'Priority for reporting (lower number = higher priority) - determines which valuation is used when multiple exist';
COMMENT ON COLUMN ref.position_type.is_official_valuation IS 'Whether this is a official book of record valuation for regulatory/accounting purposes';
COMMENT ON COLUMN ref.position_type.frequency IS 'How often positions of this type are updated: DAILY, INTRADAY, WEEKLY, MONTHLY';
COMMENT ON COLUMN ref.position_type.business_day_offset IS 'Business day offset for this position type (0=same day, -1=previous day, +1=next day)';
COMMENT ON COLUMN ref.position_type.is_system IS 'Whether this record is system-provided (shipped with Quadra) or organization-specific';
COMMENT ON COLUMN ref.position_type.is_active IS 'Whether this position type is currently active';

-- Canonical reference catalogue for held securities and contracts using meaningful codes as primary keys
CREATE TABLE ref.instrument_type (
  instrument_type_code text NOT NULL PRIMARY KEY, -- Uppercase business code like CORP_BOND, COMMON_STOCK, INTEREST_RATE_SWAP, or OPEN_END_FUND (TEXT per PostgreSQL principles)
  name text NOT NULL, -- Display name for the instrument type
  description text NULL, -- Detailed explanation of this instrument type
  category text NOT NULL,
  subcategory text NULL,
  is_marketable boolean NULL DEFAULT TRUE, -- Whether this instrument type can be traded on public markets
  is_derivative boolean NULL DEFAULT FALSE, -- Whether this is a derivative instrument (options, futures, swaps, etc.)
  requires_pricing boolean NULL DEFAULT TRUE, -- Whether this instrument type requires market pricing (false for cash)
  supports_fractional_shares boolean NULL DEFAULT FALSE, -- Whether positions can have fractional quantities (true for funds, false for most stocks)
  regulatory_category text NULL, -- Regulatory classification: SEC_REGISTERED, EXEMPT_SECURITY, COMMODITY, etc.
  sec_classification text NULL, -- SEC-specific classification if applicable (e.g., NPORT asset category codes)
  pricing_method text NULL,
  valuation_frequency text NULL,
  type_config jsonb NULL, -- Catalogue metadata with consistent cfi_groups and bloomberg_security_type_examples string arrays; hints only, not source mappings
  is_system boolean NOT NULL DEFAULT FALSE, -- Whether this record is system-provided (shipped with Quadra) or organization-specific
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this instrument type is currently active
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE ref.instrument_type IS 'Canonical reference catalogue for held securities and contracts using meaningful codes as primary keys';
COMMENT ON COLUMN ref.instrument_type.instrument_type_code IS 'Uppercase business code like CORP_BOND, COMMON_STOCK, INTEREST_RATE_SWAP, or OPEN_END_FUND (TEXT per PostgreSQL principles)';
COMMENT ON COLUMN ref.instrument_type.name IS 'Display name for the instrument type';
COMMENT ON COLUMN ref.instrument_type.description IS 'Detailed explanation of this instrument type';
COMMENT ON COLUMN ref.instrument_type.is_marketable IS 'Whether this instrument type can be traded on public markets';
COMMENT ON COLUMN ref.instrument_type.is_derivative IS 'Whether this is a derivative instrument (options, futures, swaps, etc.)';
COMMENT ON COLUMN ref.instrument_type.requires_pricing IS 'Whether this instrument type requires market pricing (false for cash)';
COMMENT ON COLUMN ref.instrument_type.supports_fractional_shares IS 'Whether positions can have fractional quantities (true for funds, false for most stocks)';
COMMENT ON COLUMN ref.instrument_type.regulatory_category IS 'Regulatory classification: SEC_REGISTERED, EXEMPT_SECURITY, COMMODITY, etc.';
COMMENT ON COLUMN ref.instrument_type.sec_classification IS 'SEC-specific classification if applicable (e.g., NPORT asset category codes)';
COMMENT ON COLUMN ref.instrument_type.type_config IS 'Catalogue metadata with consistent cfi_groups and bloomberg_security_type_examples string arrays; hints only, not source mappings';
COMMENT ON COLUMN ref.instrument_type.is_system IS 'Whether this record is system-provided (shipped with Quadra) or organization-specific';
COMMENT ON COLUMN ref.instrument_type.is_active IS 'Whether this instrument type is currently active';

-- Current state securities master with all identifiers stored as columns, using surrogate keys for high-cardinality data
CREATE TABLE core.instrument (
  instrument_id bigint NOT NULL PRIMARY KEY, -- Master identity issued by mdm.master_key (MDM-managed).
  name text NOT NULL, -- Official instrument name
  short_name text NULL, -- Short/display name for UI
  instrument_type_code text NOT NULL, -- Canonical held security or contract type (COMMON_STOCK, CORP_BOND, OPTION, etc.)
  issuer_id bigint NULL, -- Reference to issuer (FIBO: is issued by)
  cusip character varying(12) NULL, -- Committee on Uniform Securities Identification Procedures identifier (9-12 characters)
  isin character varying(12) NULL, -- International Securities Identification Number (12 characters)
  sedol character varying(7) NULL, -- Stock Exchange Daily Official List identifier (7-character alphanumeric)
  figi character varying(12) NULL, -- Financial Instrument Global Identifier (12-character Bloomberg Global ID)
  cins character varying(9) NULL, -- CUSIP International Numbering System identifier (9-character alphanumeric)
  ppn character varying(12) NULL, -- Private Placement Number: primary identifier for Rule 144A and privately placed securities on NAIC Schedule D. Mutually exclusive with CUSIP for a given issuance.
  ticker character varying(50) NULL, -- Trading ticker symbol (e.g., AAPL, MSFT)
  reuters_ric text NULL, -- Reuters Instrument Code
  other_identifiers jsonb NULL DEFAULT '[]'::jsonb, -- JSONB array of unstructured identifiers from source systems
  currency_code character varying(3) NOT NULL CHECK ((length(currency_code::text) = 3)), -- ISO 4217 currency code for denomination (USD, EUR, etc.)
  country_of_risk character varying(2) NULL, -- ISO 3166-1 alpha-2 country code where primary risk resides
  country_of_incorporation character varying(2) NULL, -- ISO 3166-1 alpha-2 country code where instrument is legally incorporated/domiciled
  primary_exchange_code text NULL, -- Primary exchange where instrument is traded (NYSE, NASDAQ, LSE, etc.)
  listing_status text NULL,
  trading_status text NULL,
  maturity_date date NULL, -- Maturity date for fixed income instruments (must be after issue_date)
  issue_date date NULL, -- Date when instrument was issued/IPO date
  coupon_rate numeric(10,6) NULL, -- Annual coupon rate for fixed income (as decimal, e.g., 0.05 for 5%)
  coupon_frequency integer NULL CHECK ((coupon_frequency IS NULL OR (coupon_frequency = ANY (ARRAY[1, 2, 4, 12])))), -- Coupon payment frequency per year (1=annual, 2=semi-annual, 4=quarterly, 12=monthly)
  face_value numeric(25,6) NULL, -- Face/par value of the instrument (for bonds, preferred stock, etc.)
  underlying_instrument_id bigint NULL, -- For derivatives: reference to the underlying instrument
  portfolio_code text NULL, -- For fund instruments: reference to the portfolio representing the fund's holdings
  parent_instrument_id bigint NULL, -- For multi-leg instruments (swaps, structured products): reference to parent instrument (NULL for standalone or parent itself)
  leg_sequence integer NULL, -- For multi-leg instruments: sequence number of this leg (1, 2, 3...). NULL for standalone instruments
  strike_price numeric(25,6) NULL, -- Strike price for options and warrants
  expiry_date date NULL, -- Expiration date for derivatives
  option_type text NULL,
  contract_size numeric(25,2) NULL, -- Contract size for derivatives (number of underlying units per contract)
  trade_date date NULL, -- Trade execution date (for OTC instruments, may differ from issue_date for bilateral trades)
  settlement_date date NULL, -- Settlement date (for FX forwards, futures, different from expiry_date/maturity_date)
  day_count_convention text NULL, -- Day count convention: 30/360, ACT/360, ACT/ACT, ACT/365, 30E/360, 30E/360_ISDA
  payment_frequency integer NULL CHECK ((payment_frequency IS NULL OR (payment_frequency = ANY (ARRAY[1, 2, 4, 12])))), -- Payment frequency per year for swaps (may differ from coupon_frequency)
  floating_rate_index text NULL, -- Floating rate index: LIBOR_3M, SOFR, EURIBOR_6M, SONIA, ESTR, etc.
  spread_over_index numeric(10,6) NULL, -- Spread over floating rate index (as decimal, e.g., 0.0025 for 25bps)
  reset_frequency integer NULL CHECK ((reset_frequency IS NULL OR (reset_frequency = ANY (ARRAY[1, 2, 4, 12])))), -- Rate reset frequency per year (for floating rate instruments, swaps)
  barrier_level numeric(25,6) NULL, -- Barrier level for barrier options/structured products (knock-in/knock-out level)
  cap_level numeric(25,6) NULL, -- Cap level for capped products (maximum payoff level)
  floor_level numeric(25,6) NULL, -- Floor level for floored products (minimum payoff level)
  payoff_description text NULL, -- Description of payoff formula for complex structured products (autocallables, range accruals, etc.)
  seniority_level text NULL,
  collateral_type text NULL,
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether instrument is currently active in the system
  is_deleted boolean NOT NULL DEFAULT FALSE CHECK (is_deleted = false OR is_active = false), -- Logical deletion flag for instrument records
  status_reason text NULL, -- Explanation for current status (e.g., delisted reason, suspension explanation)
  data_quality_score integer NULL CHECK ((data_quality_score >= 0 AND data_quality_score <= 100)), -- Computed quality score 0-100 based on identifier completeness and validation
  identifier_confidence text NULL,
  instrument_attributes jsonb NULL DEFAULT '{}'::jsonb, -- Flexible attributes for instrument-specific data, including varying third-party data structures (current state only)
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE core.instrument IS 'Current state securities master with all identifiers stored as columns, using surrogate keys for high-cardinality data';
COMMENT ON COLUMN core.instrument.instrument_id IS 'Master identity issued by mdm.master_key (MDM-managed).';
COMMENT ON COLUMN core.instrument.name IS 'Official instrument name';
COMMENT ON COLUMN core.instrument.short_name IS 'Short/display name for UI';
COMMENT ON COLUMN core.instrument.instrument_type_code IS 'Canonical held security or contract type (COMMON_STOCK, CORP_BOND, OPTION, etc.)';
COMMENT ON COLUMN core.instrument.issuer_id IS 'Reference to issuer (FIBO: is issued by)';
COMMENT ON COLUMN core.instrument.cusip IS 'Committee on Uniform Securities Identification Procedures identifier (9-12 characters)';
COMMENT ON COLUMN core.instrument.isin IS 'International Securities Identification Number (12 characters)';
COMMENT ON COLUMN core.instrument.sedol IS 'Stock Exchange Daily Official List identifier (7-character alphanumeric)';
COMMENT ON COLUMN core.instrument.figi IS 'Financial Instrument Global Identifier (12-character Bloomberg Global ID)';
COMMENT ON COLUMN core.instrument.cins IS 'CUSIP International Numbering System identifier (9-character alphanumeric)';
COMMENT ON COLUMN core.instrument.ppn IS 'Private Placement Number: primary identifier for Rule 144A and privately placed securities on NAIC Schedule D. Mutually exclusive with CUSIP for a given issuance.';
COMMENT ON COLUMN core.instrument.ticker IS 'Trading ticker symbol (e.g., AAPL, MSFT)';
COMMENT ON COLUMN core.instrument.reuters_ric IS 'Reuters Instrument Code';
COMMENT ON COLUMN core.instrument.other_identifiers IS 'JSONB array of unstructured identifiers from source systems';
COMMENT ON COLUMN core.instrument.currency_code IS 'ISO 4217 currency code for denomination (USD, EUR, etc.)';
COMMENT ON COLUMN core.instrument.country_of_risk IS 'ISO 3166-1 alpha-2 country code where primary risk resides';
COMMENT ON COLUMN core.instrument.country_of_incorporation IS 'ISO 3166-1 alpha-2 country code where instrument is legally incorporated/domiciled';
COMMENT ON COLUMN core.instrument.primary_exchange_code IS 'Primary exchange where instrument is traded (NYSE, NASDAQ, LSE, etc.)';
COMMENT ON COLUMN core.instrument.maturity_date IS 'Maturity date for fixed income instruments (must be after issue_date)';
COMMENT ON COLUMN core.instrument.issue_date IS 'Date when instrument was issued/IPO date';
COMMENT ON COLUMN core.instrument.coupon_rate IS 'Annual coupon rate for fixed income (as decimal, e.g., 0.05 for 5%)';
COMMENT ON COLUMN core.instrument.coupon_frequency IS 'Coupon payment frequency per year (1=annual, 2=semi-annual, 4=quarterly, 12=monthly)';
COMMENT ON COLUMN core.instrument.face_value IS 'Face/par value of the instrument (for bonds, preferred stock, etc.)';
COMMENT ON COLUMN core.instrument.underlying_instrument_id IS 'For derivatives: reference to the underlying instrument';
COMMENT ON COLUMN core.instrument.portfolio_code IS 'For fund instruments: reference to the portfolio representing the fund''s holdings';
COMMENT ON COLUMN core.instrument.parent_instrument_id IS 'For multi-leg instruments (swaps, structured products): reference to parent instrument (NULL for standalone or parent itself)';
COMMENT ON COLUMN core.instrument.leg_sequence IS 'For multi-leg instruments: sequence number of this leg (1, 2, 3...). NULL for standalone instruments';
COMMENT ON COLUMN core.instrument.strike_price IS 'Strike price for options and warrants';
COMMENT ON COLUMN core.instrument.expiry_date IS 'Expiration date for derivatives';
COMMENT ON COLUMN core.instrument.contract_size IS 'Contract size for derivatives (number of underlying units per contract)';
COMMENT ON COLUMN core.instrument.trade_date IS 'Trade execution date (for OTC instruments, may differ from issue_date for bilateral trades)';
COMMENT ON COLUMN core.instrument.settlement_date IS 'Settlement date (for FX forwards, futures, different from expiry_date/maturity_date)';
COMMENT ON COLUMN core.instrument.day_count_convention IS 'Day count convention: 30/360, ACT/360, ACT/ACT, ACT/365, 30E/360, 30E/360_ISDA';
COMMENT ON COLUMN core.instrument.payment_frequency IS 'Payment frequency per year for swaps (may differ from coupon_frequency)';
COMMENT ON COLUMN core.instrument.floating_rate_index IS 'Floating rate index: LIBOR_3M, SOFR, EURIBOR_6M, SONIA, ESTR, etc.';
COMMENT ON COLUMN core.instrument.spread_over_index IS 'Spread over floating rate index (as decimal, e.g., 0.0025 for 25bps)';
COMMENT ON COLUMN core.instrument.reset_frequency IS 'Rate reset frequency per year (for floating rate instruments, swaps)';
COMMENT ON COLUMN core.instrument.barrier_level IS 'Barrier level for barrier options/structured products (knock-in/knock-out level)';
COMMENT ON COLUMN core.instrument.cap_level IS 'Cap level for capped products (maximum payoff level)';
COMMENT ON COLUMN core.instrument.floor_level IS 'Floor level for floored products (minimum payoff level)';
COMMENT ON COLUMN core.instrument.payoff_description IS 'Description of payoff formula for complex structured products (autocallables, range accruals, etc.)';
COMMENT ON COLUMN core.instrument.is_active IS 'Whether instrument is currently active in the system';
COMMENT ON COLUMN core.instrument.is_deleted IS 'Logical deletion flag for instrument records';
COMMENT ON COLUMN core.instrument.status_reason IS 'Explanation for current status (e.g., delisted reason, suspension explanation)';
COMMENT ON COLUMN core.instrument.data_quality_score IS 'Computed quality score 0-100 based on identifier completeness and validation';
COMMENT ON COLUMN core.instrument.instrument_attributes IS 'Flexible attributes for instrument-specific data, including varying third-party data structures (current state only)';

-- Investment strategy reference table for portfolio strategy definitions and constraints
CREATE TABLE ref.investment_strategy (
  strategy_code text NOT NULL PRIMARY KEY, -- Unique business code identifying the strategy (e.g., GROWTH, VALUE, INCOME, BALANCED, ABSOLUTE_RETURN)
  name text NOT NULL, -- Display name for the investment strategy
  description text NULL, -- Detailed description of the strategy, its objectives, and approach
  strategy_type text NOT NULL,
  investment_style text NULL,
  risk_level text NULL,
  time_horizon text NULL,
  liquidity_requirement text NULL,
  target_return_annual numeric(10,6) NULL, -- Target annual return as decimal (e.g., 0.08 for 8% target return) - used for strategy benchmarking
  target_volatility numeric(10,6) NULL, -- Target annualized volatility as decimal (e.g., 0.15 for 15% volatility) - risk constraint for portfolio construction
  max_drawdown_limit numeric(10,6) NULL, -- Maximum acceptable drawdown as decimal (e.g., -0.20 for -20% max drawdown) - risk limit for monitoring
  is_system boolean NOT NULL DEFAULT FALSE, -- Whether this record is system-provided (shipped with Quadra) or organization-specific
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this investment strategy is currently active
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE ref.investment_strategy IS 'Investment strategy reference table for portfolio strategy definitions and constraints';
COMMENT ON COLUMN ref.investment_strategy.strategy_code IS 'Unique business code identifying the strategy (e.g., GROWTH, VALUE, INCOME, BALANCED, ABSOLUTE_RETURN)';
COMMENT ON COLUMN ref.investment_strategy.name IS 'Display name for the investment strategy';
COMMENT ON COLUMN ref.investment_strategy.description IS 'Detailed description of the strategy, its objectives, and approach';
COMMENT ON COLUMN ref.investment_strategy.target_return_annual IS 'Target annual return as decimal (e.g., 0.08 for 8% target return) - used for strategy benchmarking';
COMMENT ON COLUMN ref.investment_strategy.target_volatility IS 'Target annualized volatility as decimal (e.g., 0.15 for 15% volatility) - risk constraint for portfolio construction';
COMMENT ON COLUMN ref.investment_strategy.max_drawdown_limit IS 'Maximum acceptable drawdown as decimal (e.g., -0.20 for -20% max drawdown) - risk limit for monitoring';
COMMENT ON COLUMN ref.investment_strategy.is_system IS 'Whether this record is system-provided (shipped with Quadra) or organization-specific';
COMMENT ON COLUMN ref.investment_strategy.is_active IS 'Whether this investment strategy is currently active';

-- Reference table for portfolio strategy classifications using meaningful codes as primary keys
CREATE TABLE ref.portfolio_type (
  portfolio_type_code text NOT NULL PRIMARY KEY, -- Unique business code for portfolio type (e.g., MUTUAL_FUND, HEDGE_FUND, PENSION, ENDOWMENT, FAMILY_OFFICE)
  name text NOT NULL, -- Display name for the portfolio type
  description text NULL, -- Detailed explanation of this portfolio type
  category text NULL,
  subcategory text NULL,
  regulatory_classification text NULL,
  is_system boolean NOT NULL DEFAULT FALSE, -- Whether this record is system-provided (shipped with Quadra) or organization-specific
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this portfolio type is currently in use
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE ref.portfolio_type IS 'Reference table for portfolio strategy classifications using meaningful codes as primary keys';
COMMENT ON COLUMN ref.portfolio_type.portfolio_type_code IS 'Unique business code for portfolio type (e.g., MUTUAL_FUND, HEDGE_FUND, PENSION, ENDOWMENT, FAMILY_OFFICE)';
COMMENT ON COLUMN ref.portfolio_type.name IS 'Display name for the portfolio type';
COMMENT ON COLUMN ref.portfolio_type.description IS 'Detailed explanation of this portfolio type';
COMMENT ON COLUMN ref.portfolio_type.is_system IS 'Whether this record is system-provided (shipped with Quadra) or organization-specific';
COMMENT ON COLUMN ref.portfolio_type.is_active IS 'Whether this portfolio type is currently in use';

-- Portfolio master using meaningful business codes, with first-class fields for strategy and risk parameters
CREATE TABLE core.portfolio (
  portfolio_code text NOT NULL PRIMARY KEY, -- Meaningful business code like GROWTH_001, INCOME_CORE, HEDGE_ALPHA
  name text NOT NULL, -- Display name for the portfolio
  portfolio_type_code text NOT NULL, -- Type of portfolio (MUTUAL_FUND, HEDGE_FUND, etc.)
  strategy_code text NULL, -- Investment strategy employed by this portfolio
  base_currency_code character varying(3) NOT NULL, -- Base currency for portfolio valuation and reporting
  inception_date date NULL, -- Date when portfolio was established/launched
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether portfolio is currently active
  is_deleted boolean NOT NULL DEFAULT FALSE CHECK (is_deleted = false OR is_active = false), -- Logical deletion flag for portfolio records
  termination_date date NULL, -- Date when portfolio was terminated/closed
  investment_objective text NULL, -- Description of portfolio's investment objectives and goals
  risk_profile text NULL, -- Risk profile description or classification
  status text NULL, -- Workflow status (e.g., VERIFIED, PENDING_APPROVAL) - optional by default
  portfolio_attributes jsonb NULL DEFAULT '{}'::jsonb, -- Flexible attributes for portfolio-specific data
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE core.portfolio IS 'Portfolio master using meaningful business codes, with first-class fields for strategy and risk parameters';
COMMENT ON COLUMN core.portfolio.portfolio_code IS 'Meaningful business code like GROWTH_001, INCOME_CORE, HEDGE_ALPHA';
COMMENT ON COLUMN core.portfolio.name IS 'Display name for the portfolio';
COMMENT ON COLUMN core.portfolio.portfolio_type_code IS 'Type of portfolio (MUTUAL_FUND, HEDGE_FUND, etc.)';
COMMENT ON COLUMN core.portfolio.strategy_code IS 'Investment strategy employed by this portfolio';
COMMENT ON COLUMN core.portfolio.base_currency_code IS 'Base currency for portfolio valuation and reporting';
COMMENT ON COLUMN core.portfolio.inception_date IS 'Date when portfolio was established/launched';
COMMENT ON COLUMN core.portfolio.is_active IS 'Whether portfolio is currently active';
COMMENT ON COLUMN core.portfolio.is_deleted IS 'Logical deletion flag for portfolio records';
COMMENT ON COLUMN core.portfolio.termination_date IS 'Date when portfolio was terminated/closed';
COMMENT ON COLUMN core.portfolio.investment_objective IS 'Description of portfolio''s investment objectives and goals';
COMMENT ON COLUMN core.portfolio.risk_profile IS 'Risk profile description or classification';
COMMENT ON COLUMN core.portfolio.status IS 'Workflow status (e.g., VERIFIED, PENDING_APPROVAL) - optional by default';
COMMENT ON COLUMN core.portfolio.portfolio_attributes IS 'Flexible attributes for portfolio-specific data';

-- Reference table for transaction type classifications
CREATE TABLE ref.transaction_type (
  transaction_type_code text NOT NULL PRIMARY KEY, -- Transaction type code: BUY, SELL, SHORT_SELL, COVER, TRANSFER_IN, TRANSFER_OUT, DIVIDEND, INTEREST, SPLIT, SPINOFF, MERGER, EXERCISE, EXPIRE, ASSIGN
  name text NOT NULL, -- Human-readable transaction type name
  description text NULL, -- Detailed description of the transaction type
  is_system boolean NOT NULL DEFAULT FALSE, -- Whether this record is system-provided (shipped with Quadra) or organization-specific
  is_active boolean NOT NULL DEFAULT TRUE,
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE ref.transaction_type IS 'Reference table for transaction type classifications';
COMMENT ON COLUMN ref.transaction_type.transaction_type_code IS 'Transaction type code: BUY, SELL, SHORT_SELL, COVER, TRANSFER_IN, TRANSFER_OUT, DIVIDEND, INTEREST, SPLIT, SPINOFF, MERGER, EXERCISE, EXPIRE, ASSIGN';
COMMENT ON COLUMN ref.transaction_type.name IS 'Human-readable transaction type name';
COMMENT ON COLUMN ref.transaction_type.description IS 'Detailed description of the transaction type';
COMMENT ON COLUMN ref.transaction_type.is_system IS 'Whether this record is system-provided (shipped with Quadra) or organization-specific';

-- Trade transactions and activity - captures all buy/sell/transfer/corporate actions for portfolios
CREATE TABLE core.transaction (
  transaction_id bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL PRIMARY KEY, -- Auto-generated surrogate primary key for transaction records
  portfolio_code text NOT NULL, -- Reference to portfolio executing this transaction
  instrument_id bigint NOT NULL, -- Reference to the financial instrument being traded
  trade_date date NOT NULL, -- Date when trade was executed in the market
  settlement_date date NULL, -- Date when trade settles (cash and securities exchanged)
  record_date date NOT NULL, -- Date when transaction was recorded/booked/posted in the system
  transaction_type_code text NOT NULL, -- Transaction classification
  book_type_code text NOT NULL DEFAULT 'DEFAULT', -- Book of record this row belongs to (DEFAULT, IBOR, ABOR, PBOR, CBOR, EBOR, TBOR); an independent view, not an alias of another book. The same trade can be held once per book
  transaction_status text NOT NULL DEFAULT 'PENDING', -- Transaction lifecycle status: PENDING, CONFIRMED, SETTLED, CANCELLED, FAILED
  quantity numeric(25,6) NOT NULL, -- Number of units traded (positive for buys/receipts, negative for sells/deliveries)
  price_local numeric(25,6) NULL, -- Execution price per unit in local currency (null for transfers, corporate actions)
  price_base numeric(25,6) NULL, -- Execution price per unit in base currency (null for transfers, corporate actions)
  gross_amount_local numeric(25,2) NULL, -- Gross transaction value in local currency (quantity * price_local)
  gross_amount_base numeric(25,2) NULL, -- Gross transaction value in base currency (quantity * price_base)
  commission_local numeric(25,2) NULL DEFAULT 0, -- Brokerage commission in local currency
  commission_base numeric(25,2) NULL DEFAULT 0, -- Brokerage commission in base currency
  tax_local numeric(25,2) NULL DEFAULT 0, -- Transaction taxes in local currency (stamp duty, financial transaction tax)
  tax_base numeric(25,2) NULL DEFAULT 0, -- Transaction taxes in base currency
  fees_local numeric(25,2) NULL DEFAULT 0, -- Transaction fees in local currency (exchange fees, clearing fees, custody fees)
  fees_base numeric(25,2) NULL DEFAULT 0, -- Transaction fees in base currency
  other_charges_local numeric(25,2) NULL DEFAULT 0, -- Other miscellaneous charges in local currency (not classified as commission/tax/fees)
  other_charges_base numeric(25,2) NULL DEFAULT 0, -- Other miscellaneous charges in base currency
  net_amount_local numeric(25,2) NULL, -- Net cash flow in local currency (gross ± commission ± tax ± fees ± other_charges)
  net_amount_base numeric(25,2) NULL, -- Net cash flow in base currency (gross ± commission ± tax ± fees)
  base_currency_code character varying(3) NOT NULL, -- Portfolio's base currency for reporting
  local_currency_code character varying(3) NULL, -- Instrument's local/trading currency
  fx_rate_base_to_local numeric(15,8) NULL, -- FX rate from base currency to local currency at trade execution
  trade_reference text NULL, -- Internal trade reference number or order ID
  external_trade_id text NULL, -- External trade identifier (broker confirmation number, exchange trade ID)
  settlement_reference text NULL, -- Settlement instruction reference (custodian reference, SWIFT message reference)
  execution_venue text NULL, -- Market or venue where trade executed (NYSE, NASDAQ, LSE, OTC)
  capacity text NULL, -- Trading capacity: PRINCIPAL, AGENCY, RISKLESS_PRINCIPAL
  settlement_method text NULL, -- Settlement method: DVP (Delivery vs Payment), RVP (Receive vs Payment), FOP (Free of Payment)
  accrued_interest_local numeric(25,2) NULL, -- Accrued interest paid/received in local currency (for fixed income)
  accrued_interest_base numeric(25,2) NULL, -- Accrued interest paid/received in base currency
  realized_pnl_local numeric(25,2) NULL, -- Realized profit/loss in local currency (for closing transactions)
  realized_pnl_base numeric(25,2) NULL, -- Realized profit/loss in base currency (for closing transactions)
  cost_basis_method text NULL, -- Cost basis method used for P&L calculation: FIFO, LIFO, AVERAGE_COST, SPECIFIC_LOT
  lot_id text NULL, -- Tax lot identifier for specific lot identification
  trade_comment text NULL, -- User comment or notes about the trade
  transaction_attributes jsonb NULL DEFAULT '{}'::jsonb, -- Additional transaction-specific data in JSON format (order details, execution algorithm, market conditions)
  source_code text NULL, -- Source system providing transaction data (trading system, custodian feed, manual entry)
  is_cancelled boolean NOT NULL DEFAULT FALSE, -- Flag indicating if transaction was cancelled or voided
  cancelled_transaction_id bigint NULL, -- Reference to the original transaction if this is a cancellation transaction
  cancellation_reason text NULL, -- Reason for transaction cancellation (trade break, settlement fail, correction)
  status text NULL, -- Transaction status (e.g., CANCELLED, PENDING) - optional by default
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE core.transaction IS 'Trade transactions and activity - captures all buy/sell/transfer/corporate actions for portfolios';
COMMENT ON COLUMN core.transaction.transaction_id IS 'Auto-generated surrogate primary key for transaction records';
COMMENT ON COLUMN core.transaction.portfolio_code IS 'Reference to portfolio executing this transaction';
COMMENT ON COLUMN core.transaction.instrument_id IS 'Reference to the financial instrument being traded';
COMMENT ON COLUMN core.transaction.trade_date IS 'Date when trade was executed in the market';
COMMENT ON COLUMN core.transaction.settlement_date IS 'Date when trade settles (cash and securities exchanged)';
COMMENT ON COLUMN core.transaction.record_date IS 'Date when transaction was recorded/booked/posted in the system';
COMMENT ON COLUMN core.transaction.transaction_type_code IS 'Transaction classification';
COMMENT ON COLUMN core.transaction.book_type_code IS 'Book of record this row belongs to (DEFAULT, IBOR, ABOR, PBOR, CBOR, EBOR, TBOR); an independent view, not an alias of another book. The same trade can be held once per book';
COMMENT ON COLUMN core.transaction.transaction_status IS 'Transaction lifecycle status: PENDING, CONFIRMED, SETTLED, CANCELLED, FAILED';
COMMENT ON COLUMN core.transaction.quantity IS 'Number of units traded (positive for buys/receipts, negative for sells/deliveries)';
COMMENT ON COLUMN core.transaction.price_local IS 'Execution price per unit in local currency (null for transfers, corporate actions)';
COMMENT ON COLUMN core.transaction.price_base IS 'Execution price per unit in base currency (null for transfers, corporate actions)';
COMMENT ON COLUMN core.transaction.gross_amount_local IS 'Gross transaction value in local currency (quantity * price_local)';
COMMENT ON COLUMN core.transaction.gross_amount_base IS 'Gross transaction value in base currency (quantity * price_base)';
COMMENT ON COLUMN core.transaction.commission_local IS 'Brokerage commission in local currency';
COMMENT ON COLUMN core.transaction.commission_base IS 'Brokerage commission in base currency';
COMMENT ON COLUMN core.transaction.tax_local IS 'Transaction taxes in local currency (stamp duty, financial transaction tax)';
COMMENT ON COLUMN core.transaction.tax_base IS 'Transaction taxes in base currency';
COMMENT ON COLUMN core.transaction.fees_local IS 'Transaction fees in local currency (exchange fees, clearing fees, custody fees)';
COMMENT ON COLUMN core.transaction.fees_base IS 'Transaction fees in base currency';
COMMENT ON COLUMN core.transaction.other_charges_local IS 'Other miscellaneous charges in local currency (not classified as commission/tax/fees)';
COMMENT ON COLUMN core.transaction.other_charges_base IS 'Other miscellaneous charges in base currency';
COMMENT ON COLUMN core.transaction.net_amount_local IS 'Net cash flow in local currency (gross ± commission ± tax ± fees ± other_charges)';
COMMENT ON COLUMN core.transaction.net_amount_base IS 'Net cash flow in base currency (gross ± commission ± tax ± fees)';
COMMENT ON COLUMN core.transaction.base_currency_code IS 'Portfolio''s base currency for reporting';
COMMENT ON COLUMN core.transaction.local_currency_code IS 'Instrument''s local/trading currency';
COMMENT ON COLUMN core.transaction.fx_rate_base_to_local IS 'FX rate from base currency to local currency at trade execution';
COMMENT ON COLUMN core.transaction.trade_reference IS 'Internal trade reference number or order ID';
COMMENT ON COLUMN core.transaction.external_trade_id IS 'External trade identifier (broker confirmation number, exchange trade ID)';
COMMENT ON COLUMN core.transaction.settlement_reference IS 'Settlement instruction reference (custodian reference, SWIFT message reference)';
COMMENT ON COLUMN core.transaction.execution_venue IS 'Market or venue where trade executed (NYSE, NASDAQ, LSE, OTC)';
COMMENT ON COLUMN core.transaction.capacity IS 'Trading capacity: PRINCIPAL, AGENCY, RISKLESS_PRINCIPAL';
COMMENT ON COLUMN core.transaction.settlement_method IS 'Settlement method: DVP (Delivery vs Payment), RVP (Receive vs Payment), FOP (Free of Payment)';
COMMENT ON COLUMN core.transaction.accrued_interest_local IS 'Accrued interest paid/received in local currency (for fixed income)';
COMMENT ON COLUMN core.transaction.accrued_interest_base IS 'Accrued interest paid/received in base currency';
COMMENT ON COLUMN core.transaction.realized_pnl_local IS 'Realized profit/loss in local currency (for closing transactions)';
COMMENT ON COLUMN core.transaction.realized_pnl_base IS 'Realized profit/loss in base currency (for closing transactions)';
COMMENT ON COLUMN core.transaction.cost_basis_method IS 'Cost basis method used for P&L calculation: FIFO, LIFO, AVERAGE_COST, SPECIFIC_LOT';
COMMENT ON COLUMN core.transaction.lot_id IS 'Tax lot identifier for specific lot identification';
COMMENT ON COLUMN core.transaction.trade_comment IS 'User comment or notes about the trade';
COMMENT ON COLUMN core.transaction.transaction_attributes IS 'Additional transaction-specific data in JSON format (order details, execution algorithm, market conditions)';
COMMENT ON COLUMN core.transaction.source_code IS 'Source system providing transaction data (trading system, custodian feed, manual entry)';
COMMENT ON COLUMN core.transaction.is_cancelled IS 'Flag indicating if transaction was cancelled or voided';
COMMENT ON COLUMN core.transaction.cancelled_transaction_id IS 'Reference to the original transaction if this is a cancellation transaction';
COMMENT ON COLUMN core.transaction.cancellation_reason IS 'Reason for transaction cancellation (trade break, settlement fail, correction)';
COMMENT ON COLUMN core.transaction.status IS 'Transaction status (e.g., CANCELLED, PENDING) - optional by default';

-- Portfolio position holdings with dual-currency support (base and local)
CREATE TABLE core.position (
  position_id bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL PRIMARY KEY, -- Auto-generated surrogate primary key for position records
  portfolio_code text NOT NULL, -- Reference to portfolio holding this position
  instrument_id bigint NOT NULL, -- Reference to the financial instrument held
  position_type_code text NOT NULL DEFAULT 'DEFAULT', -- Type of position valuation (EOD, INTRADAY, PRELIM, FINAL, NAV_CALC)
  book_type_code text NOT NULL DEFAULT 'DEFAULT', -- Book of record this row belongs to (DEFAULT, IBOR, ABOR, PBOR, CBOR, EBOR, TBOR); an independent view, not an alias of another book
  base_currency_code character varying(3) NOT NULL, -- Portfolio's base currency for reporting (e.g., USD for US portfolios, EUR for European portfolios)
  position_date date NOT NULL, -- Date of position observation (valuation date)
  quantity numeric(25,6) NOT NULL, -- Number of units held (can be fractional for funds, negative for short positions)
  unit_cost numeric(25,6) NULL, -- Average cost per unit in base currency (cost_base / quantity)
  cost_base numeric(25,2) NULL, -- Total acquisition cost in base currency (book value, amortized cost)
  market_value_base numeric(25,2) NULL, -- Current market value in base currency (quantity * price * fx_rate)
  unrealized_pnl_base numeric(25,2) NULL, -- Unrealized profit/loss in base currency (market_value_base - cost_base)
  accrued_income_base numeric(25,2) NULL DEFAULT 0, -- Accrued interest or dividends in base currency (for fixed income, preferred stock)
  cost_local numeric(25,2) NULL, -- Total acquisition cost in instrument's local/trading currency (for multi-currency positions)
  market_value_local numeric(25,2) NULL, -- Current market value in instrument's local/trading currency (quantity * local_price)
  exposure_base numeric(25,2) NULL, -- Economic exposure in base currency (for derivatives, this may differ from market_value due to notional amounts, leverage, delta adjustment)
  exposure_local numeric(25,2) NULL, -- Economic exposure in local currency (notional exposure for derivatives, market value for cash instruments)
  local_currency_code character varying(3) NULL, -- Instrument's local/trading currency (e.g., JPY for Tokyo-listed stock, GBP for LSE-listed stock)
  fx_rate_base_to_local numeric(15,8) NULL, -- FX rate from base currency to local currency (multiply base by this to get local)
  portfolio_market_value_base numeric(25,2) NULL, -- Total portfolio market value in base currency at position_date (for weight calculation, denormalized for performance)
  portfolio_exposure_base numeric(25,2) NULL, -- Total portfolio exposure in base currency at position_date (for exposure weight calculation, denormalized for performance)
  portfolio_weight numeric(8,4) NULL, -- Position weight as decimal (market_value_base / portfolio_market_value_base) - e.g., 0.0523 for 5.23% of portfolio
  exposure_weight numeric(8,4) NULL, -- Position exposure weight as decimal (exposure_base / portfolio_exposure_base) - economic risk weight including leverage and derivatives
  duration numeric(10,4) NULL, -- Position duration (for fixed income positions) - Macaulay or Modified duration
  yield_to_maturity numeric(8,4) NULL, -- Yield to maturity (for fixed income positions) - as decimal (e.g., 0.0425 for 4.25%)
  beta numeric(8,4) NULL, -- Position beta vs portfolio benchmark (for equity positions)
  delta numeric(8,4) NULL, -- Option delta (for derivative positions) - sensitivity to underlying price movement
  gamma numeric(8,4) NULL, -- Option gamma (for derivative positions) - rate of change of delta
  vega numeric(8,4) NULL, -- Option vega (for derivative positions) - sensitivity to implied volatility changes
  theta numeric(8,4) NULL, -- Option theta (for derivative positions) - time decay per day
  position_attributes jsonb NULL DEFAULT '{}'::jsonb, -- Flexible attributes for position-specific data, including raw data from external sources (vendor-specific fields, reconciliation data)
  source_code text NOT NULL DEFAULT 'DEFAULT', -- Source system that provided this position data (NPORT, BLOOMBERG, CUSTODIAN, INTERNAL)
  external_position_id text NULL, -- Position identifier from external source system (for reconciliation and data lineage)
  data_vendor text NULL, -- Name of data vendor if position sourced from third party (BLOOMBERG, STATE_STREET, BNY_MELLON)
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE core.position IS 'Portfolio position holdings with dual-currency support (base and local)';
COMMENT ON COLUMN core.position.position_id IS 'Auto-generated surrogate primary key for position records';
COMMENT ON COLUMN core.position.portfolio_code IS 'Reference to portfolio holding this position';
COMMENT ON COLUMN core.position.instrument_id IS 'Reference to the financial instrument held';
COMMENT ON COLUMN core.position.position_type_code IS 'Type of position valuation (EOD, INTRADAY, PRELIM, FINAL, NAV_CALC)';
COMMENT ON COLUMN core.position.book_type_code IS 'Book of record this row belongs to (DEFAULT, IBOR, ABOR, PBOR, CBOR, EBOR, TBOR); an independent view, not an alias of another book';
COMMENT ON COLUMN core.position.base_currency_code IS 'Portfolio''s base currency for reporting (e.g., USD for US portfolios, EUR for European portfolios)';
COMMENT ON COLUMN core.position.position_date IS 'Date of position observation (valuation date)';
COMMENT ON COLUMN core.position.quantity IS 'Number of units held (can be fractional for funds, negative for short positions)';
COMMENT ON COLUMN core.position.unit_cost IS 'Average cost per unit in base currency (cost_base / quantity)';
COMMENT ON COLUMN core.position.cost_base IS 'Total acquisition cost in base currency (book value, amortized cost)';
COMMENT ON COLUMN core.position.market_value_base IS 'Current market value in base currency (quantity * price * fx_rate)';
COMMENT ON COLUMN core.position.unrealized_pnl_base IS 'Unrealized profit/loss in base currency (market_value_base - cost_base)';
COMMENT ON COLUMN core.position.accrued_income_base IS 'Accrued interest or dividends in base currency (for fixed income, preferred stock)';
COMMENT ON COLUMN core.position.cost_local IS 'Total acquisition cost in instrument''s local/trading currency (for multi-currency positions)';
COMMENT ON COLUMN core.position.market_value_local IS 'Current market value in instrument''s local/trading currency (quantity * local_price)';
COMMENT ON COLUMN core.position.exposure_base IS 'Economic exposure in base currency (for derivatives, this may differ from market_value due to notional amounts, leverage, delta adjustment)';
COMMENT ON COLUMN core.position.exposure_local IS 'Economic exposure in local currency (notional exposure for derivatives, market value for cash instruments)';
COMMENT ON COLUMN core.position.local_currency_code IS 'Instrument''s local/trading currency (e.g., JPY for Tokyo-listed stock, GBP for LSE-listed stock)';
COMMENT ON COLUMN core.position.fx_rate_base_to_local IS 'FX rate from base currency to local currency (multiply base by this to get local)';
COMMENT ON COLUMN core.position.portfolio_market_value_base IS 'Total portfolio market value in base currency at position_date (for weight calculation, denormalized for performance)';
COMMENT ON COLUMN core.position.portfolio_exposure_base IS 'Total portfolio exposure in base currency at position_date (for exposure weight calculation, denormalized for performance)';
COMMENT ON COLUMN core.position.portfolio_weight IS 'Position weight as decimal (market_value_base / portfolio_market_value_base) - e.g., 0.0523 for 5.23% of portfolio';
COMMENT ON COLUMN core.position.exposure_weight IS 'Position exposure weight as decimal (exposure_base / portfolio_exposure_base) - economic risk weight including leverage and derivatives';
COMMENT ON COLUMN core.position.duration IS 'Position duration (for fixed income positions) - Macaulay or Modified duration';
COMMENT ON COLUMN core.position.yield_to_maturity IS 'Yield to maturity (for fixed income positions) - as decimal (e.g., 0.0425 for 4.25%)';
COMMENT ON COLUMN core.position.beta IS 'Position beta vs portfolio benchmark (for equity positions)';
COMMENT ON COLUMN core.position.delta IS 'Option delta (for derivative positions) - sensitivity to underlying price movement';
COMMENT ON COLUMN core.position.gamma IS 'Option gamma (for derivative positions) - rate of change of delta';
COMMENT ON COLUMN core.position.vega IS 'Option vega (for derivative positions) - sensitivity to implied volatility changes';
COMMENT ON COLUMN core.position.theta IS 'Option theta (for derivative positions) - time decay per day';
COMMENT ON COLUMN core.position.position_attributes IS 'Flexible attributes for position-specific data, including raw data from external sources (vendor-specific fields, reconciliation data)';
COMMENT ON COLUMN core.position.source_code IS 'Source system that provided this position data (NPORT, BLOOMBERG, CUSTODIAN, INTERNAL)';
COMMENT ON COLUMN core.position.external_position_id IS 'Position identifier from external source system (for reconciliation and data lineage)';
COMMENT ON COLUMN core.position.data_vendor IS 'Name of data vendor if position sourced from third party (BLOOMBERG, STATE_STREET, BNY_MELLON)';

-- Reference table for fund vehicle type classifications - closed-end, open-end, evergreen, and hybrid structures
CREATE TABLE fund.fund_type (
  fund_type_code text NOT NULL PRIMARY KEY, -- Unique business code: CLOSED_END, OPEN_END, EVERGREEN, INTERVAL, FUND_OF_FUNDS, CO_INVESTMENT, SECONDARY, FEEDER, MASTER
  name text NOT NULL, -- Display name for the fund type
  description text NULL, -- Detailed explanation of this fund type
  category text NULL, -- High-level grouping: CLOSED_END, OPEN_END, HYBRID
  subcategory text NULL, -- More specific subcategory: BUYOUT, VENTURE, CREDIT, REAL_ESTATE, INFRASTRUCTURE, HEDGE, MULTI_STRATEGY
  has_fixed_term boolean NOT NULL DEFAULT TRUE, -- Whether the fund has a defined lifecycle/term
  has_capital_calls boolean NOT NULL DEFAULT TRUE, -- Whether fund uses capital call mechanism (vs full upfront subscription)
  default_fund_life_years integer NULL, -- Typical fund life in years (10 for PE, 7 for credit, null for open-end)
  is_system boolean NOT NULL DEFAULT FALSE, -- Whether this record is system-provided (shipped with Quadra) or organization-specific
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this fund type is currently in use
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE fund.fund_type IS 'Reference table for fund vehicle type classifications - closed-end, open-end, evergreen, and hybrid structures';
COMMENT ON COLUMN fund.fund_type.fund_type_code IS 'Unique business code: CLOSED_END, OPEN_END, EVERGREEN, INTERVAL, FUND_OF_FUNDS, CO_INVESTMENT, SECONDARY, FEEDER, MASTER';
COMMENT ON COLUMN fund.fund_type.name IS 'Display name for the fund type';
COMMENT ON COLUMN fund.fund_type.description IS 'Detailed explanation of this fund type';
COMMENT ON COLUMN fund.fund_type.category IS 'High-level grouping: CLOSED_END, OPEN_END, HYBRID';
COMMENT ON COLUMN fund.fund_type.subcategory IS 'More specific subcategory: BUYOUT, VENTURE, CREDIT, REAL_ESTATE, INFRASTRUCTURE, HEDGE, MULTI_STRATEGY';
COMMENT ON COLUMN fund.fund_type.has_fixed_term IS 'Whether the fund has a defined lifecycle/term';
COMMENT ON COLUMN fund.fund_type.has_capital_calls IS 'Whether fund uses capital call mechanism (vs full upfront subscription)';
COMMENT ON COLUMN fund.fund_type.default_fund_life_years IS 'Typical fund life in years (10 for PE, 7 for credit, null for open-end)';
COMMENT ON COLUMN fund.fund_type.is_system IS 'Whether this record is system-provided (shipped with Quadra) or organization-specific';
COMMENT ON COLUMN fund.fund_type.is_active IS 'Whether this fund type is currently in use';

-- Master table for fund vehicles - private equity, hedge, real estate, infrastructure, credit, and other pooled investment structures
CREATE TABLE fund.fund (
  fund_id bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL PRIMARY KEY, -- Auto-generated surrogate key for fund records
  fund_code text NOT NULL UNIQUE, -- Unique business code for the fund (e.g., GROWTH_FUND_IV, CREDIT_OPP_2024)
  fund_name text NOT NULL, -- Full legal name of the fund
  party_id bigint NOT NULL UNIQUE, -- Mastered party for this fund vehicle's own legal entity; each feeder, parallel or co-invest vehicle has its own
  short_name text NULL, -- Short display name for UI
  fund_type_code text NOT NULL, -- Type of fund vehicle: CLOSED_END, OPEN_END, EVERGREEN, CO_INVESTMENT, FUND_OF_FUNDS, FEEDER, MASTER, SECONDARY
  portfolio_code text NOT NULL UNIQUE, -- Link to core portfolio (the fund IS a portfolio for position/valuation tracking)
  parent_fund_id bigint NULL, -- Parent fund for feeder/master, co-invest alongside, or fund-of-funds hierarchies
  domicile_country_code character varying(2) NULL, -- ISO 3166-1 alpha-2 country of fund domicile
  base_currency_code character varying(3) NOT NULL, -- Fund base/reporting currency
  vintage_year integer NULL, -- Vintage year (year of first capital call or first close)
  inception_date date NULL, -- Fund inception/formation date
  investment_period_end date NULL, -- End of investment period (after which new investments generally cannot be made)
  fund_term_end date NULL, -- Scheduled end of fund term (before extensions)
  extension_period_years integer NULL, -- Maximum extension period in years (typically 1-2 years)
  target_size numeric(25,2) NULL, -- Target fundraise amount in base currency
  hard_cap numeric(25,2) NULL, -- Maximum fund size (hard cap)
  final_close_amount numeric(25,2) NULL, -- Actual amount raised at final close
  gp_commitment_amount numeric(25,2) NULL, -- GP own capital commitment amount
  gp_commitment_pct numeric(8,4) NULL, -- GP commitment as percentage of total fund size
  strategy_code text NULL, -- Link to investment strategy definition
  preferred_return_rate numeric(8,4) NULL, -- Preferred return / hurdle rate as decimal (e.g., 0.08 for 8%)
  carried_interest_rate numeric(8,4) NULL, -- Carried interest percentage as decimal (e.g., 0.20 for 20%)
  catchup_rate numeric(8,4) NULL, -- GP catch-up rate as decimal (e.g., 1.00 for 100% catch-up until GP receives full carry share)
  management_fee_rate numeric(8,4) NULL, -- Standard management fee rate as decimal (e.g., 0.02 for 2%)
  has_clawback boolean NOT NULL DEFAULT FALSE, -- Whether GP has clawback obligation to return excess carried interest
  has_key_person_provision boolean NOT NULL DEFAULT FALSE, -- Whether fund has key person provisions that could trigger suspension
  fund_status text NOT NULL DEFAULT 'FORMATION', -- Fund lifecycle status: FORMATION, FUNDRAISING, INVESTING, HARVESTING, EXTENSION, LIQUIDATING, TERMINATED
  regulatory_classification text NULL,
  fund_attributes jsonb NULL DEFAULT '{}'::jsonb, -- Additional fund-specific metadata in JSON format
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this fund is currently active
  is_deleted boolean NOT NULL DEFAULT FALSE CHECK (is_deleted = false OR is_active = false), -- Logical deletion flag for fund records
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE fund.fund IS 'Master table for fund vehicles - private equity, hedge, real estate, infrastructure, credit, and other pooled investment structures';
COMMENT ON COLUMN fund.fund.fund_id IS 'Auto-generated surrogate key for fund records';
COMMENT ON COLUMN fund.fund.fund_code IS 'Unique business code for the fund (e.g., GROWTH_FUND_IV, CREDIT_OPP_2024)';
COMMENT ON COLUMN fund.fund.fund_name IS 'Full legal name of the fund';
COMMENT ON COLUMN fund.fund.party_id IS 'Mastered party for this fund vehicle''s own legal entity; each feeder, parallel or co-invest vehicle has its own';
COMMENT ON COLUMN fund.fund.short_name IS 'Short display name for UI';
COMMENT ON COLUMN fund.fund.fund_type_code IS 'Type of fund vehicle: CLOSED_END, OPEN_END, EVERGREEN, CO_INVESTMENT, FUND_OF_FUNDS, FEEDER, MASTER, SECONDARY';
COMMENT ON COLUMN fund.fund.portfolio_code IS 'Link to core portfolio (the fund IS a portfolio for position/valuation tracking)';
COMMENT ON COLUMN fund.fund.parent_fund_id IS 'Parent fund for feeder/master, co-invest alongside, or fund-of-funds hierarchies';
COMMENT ON COLUMN fund.fund.domicile_country_code IS 'ISO 3166-1 alpha-2 country of fund domicile';
COMMENT ON COLUMN fund.fund.base_currency_code IS 'Fund base/reporting currency';
COMMENT ON COLUMN fund.fund.vintage_year IS 'Vintage year (year of first capital call or first close)';
COMMENT ON COLUMN fund.fund.inception_date IS 'Fund inception/formation date';
COMMENT ON COLUMN fund.fund.investment_period_end IS 'End of investment period (after which new investments generally cannot be made)';
COMMENT ON COLUMN fund.fund.fund_term_end IS 'Scheduled end of fund term (before extensions)';
COMMENT ON COLUMN fund.fund.extension_period_years IS 'Maximum extension period in years (typically 1-2 years)';
COMMENT ON COLUMN fund.fund.target_size IS 'Target fundraise amount in base currency';
COMMENT ON COLUMN fund.fund.hard_cap IS 'Maximum fund size (hard cap)';
COMMENT ON COLUMN fund.fund.final_close_amount IS 'Actual amount raised at final close';
COMMENT ON COLUMN fund.fund.gp_commitment_amount IS 'GP own capital commitment amount';
COMMENT ON COLUMN fund.fund.gp_commitment_pct IS 'GP commitment as percentage of total fund size';
COMMENT ON COLUMN fund.fund.strategy_code IS 'Link to investment strategy definition';
COMMENT ON COLUMN fund.fund.preferred_return_rate IS 'Preferred return / hurdle rate as decimal (e.g., 0.08 for 8%)';
COMMENT ON COLUMN fund.fund.carried_interest_rate IS 'Carried interest percentage as decimal (e.g., 0.20 for 20%)';
COMMENT ON COLUMN fund.fund.catchup_rate IS 'GP catch-up rate as decimal (e.g., 1.00 for 100% catch-up until GP receives full carry share)';
COMMENT ON COLUMN fund.fund.management_fee_rate IS 'Standard management fee rate as decimal (e.g., 0.02 for 2%)';
COMMENT ON COLUMN fund.fund.has_clawback IS 'Whether GP has clawback obligation to return excess carried interest';
COMMENT ON COLUMN fund.fund.has_key_person_provision IS 'Whether fund has key person provisions that could trigger suspension';
COMMENT ON COLUMN fund.fund.fund_status IS 'Fund lifecycle status: FORMATION, FUNDRAISING, INVESTING, HARVESTING, EXTENSION, LIQUIDATING, TERMINATED';
COMMENT ON COLUMN fund.fund.fund_attributes IS 'Additional fund-specific metadata in JSON format';
COMMENT ON COLUMN fund.fund.is_active IS 'Whether this fund is currently active';
COMMENT ON COLUMN fund.fund.is_deleted IS 'Logical deletion flag for fund records';

-- Reference table for deal lifecycle stage classifications - pipeline tracking from sourcing to exit
CREATE TABLE pm.deal_stage (
  deal_stage_code text NOT NULL PRIMARY KEY, -- Unique business code: SOURCED, SCREENING, DUE_DILIGENCE, IC_REVIEW, IC_APPROVED, TERM_SHEET, COMMITTED, CLOSING, CLOSED, MONITORING, EXITING, EXITED, PASSED, WRITE_OFF
  name text NOT NULL, -- Display name for the deal stage
  description text NULL, -- Detailed explanation of this deal stage
  category text NULL, -- Stage grouping: PIPELINE, ACTIVE, REALIZED, DECLINED
  stage_sequence integer NOT NULL, -- Typical ordering for pipeline views (1 = earliest stage)
  is_terminal boolean NOT NULL DEFAULT FALSE, -- Whether this is a final/terminal state (EXITED, PASSED, WRITE_OFF)
  is_system boolean NOT NULL DEFAULT FALSE, -- Whether this record is system-provided (shipped with Quadra) or organization-specific
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this deal stage is currently in use
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE pm.deal_stage IS 'Reference table for deal lifecycle stage classifications - pipeline tracking from sourcing to exit';
COMMENT ON COLUMN pm.deal_stage.deal_stage_code IS 'Unique business code: SOURCED, SCREENING, DUE_DILIGENCE, IC_REVIEW, IC_APPROVED, TERM_SHEET, COMMITTED, CLOSING, CLOSED, MONITORING, EXITING, EXITED, PASSED, WRITE_OFF';
COMMENT ON COLUMN pm.deal_stage.name IS 'Display name for the deal stage';
COMMENT ON COLUMN pm.deal_stage.description IS 'Detailed explanation of this deal stage';
COMMENT ON COLUMN pm.deal_stage.category IS 'Stage grouping: PIPELINE, ACTIVE, REALIZED, DECLINED';
COMMENT ON COLUMN pm.deal_stage.stage_sequence IS 'Typical ordering for pipeline views (1 = earliest stage)';
COMMENT ON COLUMN pm.deal_stage.is_terminal IS 'Whether this is a final/terminal state (EXITED, PASSED, WRITE_OFF)';
COMMENT ON COLUMN pm.deal_stage.is_system IS 'Whether this record is system-provided (shipped with Quadra) or organization-specific';
COMMENT ON COLUMN pm.deal_stage.is_active IS 'Whether this deal stage is currently in use';

-- Reference table for deal/investment type classifications - buyout, growth, venture, credit, and other strategies
CREATE TABLE pm.deal_type (
  deal_type_code text NOT NULL PRIMARY KEY, -- Unique business code: BUYOUT, GROWTH_EQUITY, VENTURE, MEZZANINE, DISTRESSED, SECONDARIES, CO_INVESTMENT, DIRECT_LENDING, REAL_ESTATE, INFRASTRUCTURE, RECAPITALIZATION, CARVE_OUT, PIPE
  name text NOT NULL, -- Display name for the deal type
  description text NULL, -- Detailed explanation of this deal type
  category text NULL, -- High-level grouping: EQUITY, CREDIT, REAL_ASSETS, SPECIAL_SITUATIONS
  is_system boolean NOT NULL DEFAULT FALSE, -- Whether this record is system-provided (shipped with Quadra) or organization-specific
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this deal type is currently in use
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE pm.deal_type IS 'Reference table for deal/investment type classifications - buyout, growth, venture, credit, and other strategies';
COMMENT ON COLUMN pm.deal_type.deal_type_code IS 'Unique business code: BUYOUT, GROWTH_EQUITY, VENTURE, MEZZANINE, DISTRESSED, SECONDARIES, CO_INVESTMENT, DIRECT_LENDING, REAL_ESTATE, INFRASTRUCTURE, RECAPITALIZATION, CARVE_OUT, PIPE';
COMMENT ON COLUMN pm.deal_type.name IS 'Display name for the deal type';
COMMENT ON COLUMN pm.deal_type.description IS 'Detailed explanation of this deal type';
COMMENT ON COLUMN pm.deal_type.category IS 'High-level grouping: EQUITY, CREDIT, REAL_ASSETS, SPECIAL_SITUATIONS';
COMMENT ON COLUMN pm.deal_type.is_system IS 'Whether this record is system-provided (shipped with Quadra) or organization-specific';
COMMENT ON COLUMN pm.deal_type.is_active IS 'Whether this deal type is currently in use';

-- Investment deals - opportunities tracked from sourcing through due diligence, closing, monitoring, and exit
CREATE TABLE pm.deal (
  deal_id bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL PRIMARY KEY, -- Auto-generated surrogate key for deal records
  fund_id bigint NOT NULL, -- Primary fund making the investment
  deal_code text NULL, -- Internal deal reference code
  deal_name text NOT NULL, -- Deal name / working title
  deal_type_code text NOT NULL, -- Investment type: BUYOUT, GROWTH_EQUITY, VENTURE, MEZZANINE, etc.
  deal_stage_code text NOT NULL, -- Current lifecycle stage: SOURCED, DUE_DILIGENCE, CLOSED, EXITED, etc.
  instrument_id bigint NULL, -- Instrument representing the security acquired in this deal
  sector text NULL, -- Primary sector (may also use core classification schemes for formal taxonomy)
  geography text NULL, -- Primary geography of the investment
  source_type text NULL, -- How deal was sourced: PROPRIETARY, AUCTION, INTERMEDIARY, DIRECT, NETWORK
  entry_date date NULL, -- Date investment was made (deal close date)
  entry_ev numeric(25,2) NULL, -- Enterprise value at entry in deal currency
  entry_equity_value numeric(25,2) NULL, -- Equity value at entry in deal currency
  entry_ev_ebitda numeric(8,2) NULL, -- EV/EBITDA entry multiple
  total_invested numeric(25,2) NULL, -- Total capital invested across all tranches
  exit_date date NULL, -- Date of full or partial exit
  exit_ev numeric(25,2) NULL, -- Enterprise value at exit in deal currency
  exit_equity_value numeric(25,2) NULL, -- Equity value at exit in deal currency
  exit_ev_ebitda numeric(8,2) NULL, -- EV/EBITDA exit multiple
  total_realized numeric(25,2) NULL, -- Total proceeds realized from the investment
  deal_irr numeric(8,4) NULL, -- Deal-level gross IRR
  deal_moic numeric(8,4) NULL, -- Deal-level gross MOIC
  currency_code character varying(3) NOT NULL, -- Deal currency for all monetary values
  deal_status text NOT NULL DEFAULT 'ACTIVE', -- Deal status: ACTIVE, ON_HOLD, PASSED, EXITED, WRITTEN_OFF
  ic_approval_date date NULL, -- Investment committee approval date
  expected_hold_period_years numeric(4,1) NULL, -- Expected holding period in years
  thesis text NULL, -- Investment thesis summary
  deal_attributes jsonb NULL DEFAULT '{}'::jsonb, -- Additional deal-specific metadata
  is_active boolean NOT NULL DEFAULT TRUE, -- Whether this deal is currently active
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER,
  updated_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE pm.deal IS 'Investment deals - opportunities tracked from sourcing through due diligence, closing, monitoring, and exit';
COMMENT ON COLUMN pm.deal.deal_id IS 'Auto-generated surrogate key for deal records';
COMMENT ON COLUMN pm.deal.fund_id IS 'Primary fund making the investment';
COMMENT ON COLUMN pm.deal.deal_code IS 'Internal deal reference code';
COMMENT ON COLUMN pm.deal.deal_name IS 'Deal name / working title';
COMMENT ON COLUMN pm.deal.deal_type_code IS 'Investment type: BUYOUT, GROWTH_EQUITY, VENTURE, MEZZANINE, etc.';
COMMENT ON COLUMN pm.deal.deal_stage_code IS 'Current lifecycle stage: SOURCED, DUE_DILIGENCE, CLOSED, EXITED, etc.';
COMMENT ON COLUMN pm.deal.instrument_id IS 'Instrument representing the security acquired in this deal';
COMMENT ON COLUMN pm.deal.sector IS 'Primary sector (may also use core classification schemes for formal taxonomy)';
COMMENT ON COLUMN pm.deal.geography IS 'Primary geography of the investment';
COMMENT ON COLUMN pm.deal.source_type IS 'How deal was sourced: PROPRIETARY, AUCTION, INTERMEDIARY, DIRECT, NETWORK';
COMMENT ON COLUMN pm.deal.entry_date IS 'Date investment was made (deal close date)';
COMMENT ON COLUMN pm.deal.entry_ev IS 'Enterprise value at entry in deal currency';
COMMENT ON COLUMN pm.deal.entry_equity_value IS 'Equity value at entry in deal currency';
COMMENT ON COLUMN pm.deal.entry_ev_ebitda IS 'EV/EBITDA entry multiple';
COMMENT ON COLUMN pm.deal.total_invested IS 'Total capital invested across all tranches';
COMMENT ON COLUMN pm.deal.exit_date IS 'Date of full or partial exit';
COMMENT ON COLUMN pm.deal.exit_ev IS 'Enterprise value at exit in deal currency';
COMMENT ON COLUMN pm.deal.exit_equity_value IS 'Equity value at exit in deal currency';
COMMENT ON COLUMN pm.deal.exit_ev_ebitda IS 'EV/EBITDA exit multiple';
COMMENT ON COLUMN pm.deal.total_realized IS 'Total proceeds realized from the investment';
COMMENT ON COLUMN pm.deal.deal_irr IS 'Deal-level gross IRR';
COMMENT ON COLUMN pm.deal.deal_moic IS 'Deal-level gross MOIC';
COMMENT ON COLUMN pm.deal.currency_code IS 'Deal currency for all monetary values';
COMMENT ON COLUMN pm.deal.deal_status IS 'Deal status: ACTIVE, ON_HOLD, PASSED, EXITED, WRITTEN_OFF';
COMMENT ON COLUMN pm.deal.ic_approval_date IS 'Investment committee approval date';
COMMENT ON COLUMN pm.deal.expected_hold_period_years IS 'Expected holding period in years';
COMMENT ON COLUMN pm.deal.thesis IS 'Investment thesis summary';
COMMENT ON COLUMN pm.deal.deal_attributes IS 'Additional deal-specific metadata';
COMMENT ON COLUMN pm.deal.is_active IS 'Whether this deal is currently active';

-- MDM identity registry. FK target of core.<entity>.<entity>_id.
CREATE TABLE mdm.master_key (
  master_key_id bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL PRIMARY KEY,
  entity_type text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by text NOT NULL DEFAULT USER
);
COMMENT ON TABLE mdm.master_key IS 'MDM identity registry. FK target of core.<entity>.<entity>_id.';

-- ============================================================================
-- FOREIGN KEY CONSTRAINTS
-- Added after table creation to handle forward references
-- ============================================================================

ALTER TABLE ref.country ADD FOREIGN KEY (sovereignty_country_code) REFERENCES ref.country(country_code);
ALTER TABLE ref.exchange ADD FOREIGN KEY (country_code) REFERENCES ref.country(country_code);
ALTER TABLE ref.exchange ADD FOREIGN KEY (currency_code) REFERENCES ref.currency(currency_code);
ALTER TABLE core.issuer ADD FOREIGN KEY (issuer_id) REFERENCES mdm.master_key(master_key_id);
ALTER TABLE core.issuer ADD FOREIGN KEY (country_of_domicile) REFERENCES ref.country(country_code);
ALTER TABLE core.issuer ADD FOREIGN KEY (country_of_incorporation) REFERENCES ref.country(country_code);
ALTER TABLE core.instrument ADD FOREIGN KEY (instrument_id) REFERENCES mdm.master_key(master_key_id);
ALTER TABLE core.instrument ADD FOREIGN KEY (instrument_type_code) REFERENCES ref.instrument_type(instrument_type_code);
ALTER TABLE core.instrument ADD FOREIGN KEY (issuer_id) REFERENCES core.issuer(issuer_id);
ALTER TABLE core.instrument ADD FOREIGN KEY (currency_code) REFERENCES ref.currency(currency_code);
ALTER TABLE core.instrument ADD FOREIGN KEY (country_of_risk) REFERENCES ref.country(country_code);
ALTER TABLE core.instrument ADD FOREIGN KEY (country_of_incorporation) REFERENCES ref.country(country_code);
ALTER TABLE core.instrument ADD FOREIGN KEY (primary_exchange_code) REFERENCES ref.exchange(exchange_code);
ALTER TABLE core.instrument ADD FOREIGN KEY (underlying_instrument_id) REFERENCES core.instrument(instrument_id);
ALTER TABLE core.instrument ADD FOREIGN KEY (portfolio_code) REFERENCES core.portfolio(portfolio_code);
ALTER TABLE core.instrument ADD FOREIGN KEY (parent_instrument_id) REFERENCES core.instrument(instrument_id);
ALTER TABLE core.portfolio ADD FOREIGN KEY (portfolio_type_code) REFERENCES ref.portfolio_type(portfolio_type_code);
ALTER TABLE core.portfolio ADD FOREIGN KEY (strategy_code) REFERENCES ref.investment_strategy(strategy_code);
ALTER TABLE core.portfolio ADD FOREIGN KEY (base_currency_code) REFERENCES ref.currency(currency_code);
ALTER TABLE core.transaction ADD FOREIGN KEY (portfolio_code) REFERENCES core.portfolio(portfolio_code);
ALTER TABLE core.transaction ADD FOREIGN KEY (instrument_id) REFERENCES core.instrument(instrument_id);
ALTER TABLE core.transaction ADD FOREIGN KEY (transaction_type_code) REFERENCES ref.transaction_type(transaction_type_code);
ALTER TABLE core.transaction ADD FOREIGN KEY (base_currency_code) REFERENCES ref.currency(currency_code);
ALTER TABLE core.transaction ADD FOREIGN KEY (local_currency_code) REFERENCES ref.currency(currency_code);
ALTER TABLE core.transaction ADD FOREIGN KEY (source_code) REFERENCES ref.source(source_code);
ALTER TABLE core.transaction ADD FOREIGN KEY (cancelled_transaction_id) REFERENCES core.transaction(transaction_id);
ALTER TABLE core.position ADD FOREIGN KEY (portfolio_code) REFERENCES core.portfolio(portfolio_code);
ALTER TABLE core.position ADD FOREIGN KEY (instrument_id) REFERENCES core.instrument(instrument_id);
ALTER TABLE core.position ADD FOREIGN KEY (position_type_code) REFERENCES ref.position_type(position_type_code);
ALTER TABLE core.position ADD FOREIGN KEY (base_currency_code) REFERENCES ref.currency(currency_code);
ALTER TABLE core.position ADD FOREIGN KEY (local_currency_code) REFERENCES ref.currency(currency_code);
ALTER TABLE core.position ADD FOREIGN KEY (source_code) REFERENCES ref.source(source_code);
ALTER TABLE fund.fund ADD FOREIGN KEY (fund_type_code) REFERENCES fund.fund_type(fund_type_code);
ALTER TABLE fund.fund ADD FOREIGN KEY (portfolio_code) REFERENCES core.portfolio(portfolio_code);
ALTER TABLE fund.fund ADD FOREIGN KEY (parent_fund_id) REFERENCES fund.fund(fund_id);
ALTER TABLE fund.fund ADD FOREIGN KEY (domicile_country_code) REFERENCES ref.country(country_code);
ALTER TABLE fund.fund ADD FOREIGN KEY (base_currency_code) REFERENCES ref.currency(currency_code);
ALTER TABLE fund.fund ADD FOREIGN KEY (strategy_code) REFERENCES ref.investment_strategy(strategy_code);
ALTER TABLE pm.deal ADD FOREIGN KEY (fund_id) REFERENCES fund.fund(fund_id);
ALTER TABLE pm.deal ADD FOREIGN KEY (deal_type_code) REFERENCES pm.deal_type(deal_type_code);
ALTER TABLE pm.deal ADD FOREIGN KEY (deal_stage_code) REFERENCES pm.deal_stage(deal_stage_code);
ALTER TABLE pm.deal ADD FOREIGN KEY (instrument_id) REFERENCES core.instrument(instrument_id);
ALTER TABLE pm.deal ADD FOREIGN KEY (currency_code) REFERENCES ref.currency(currency_code);

-- ============================================================================
-- MANAGED INDEXES
-- Unique business keys and PostgreSQL access-path indexes declared in AML
-- ============================================================================
CREATE INDEX idx_position_explorer_portfolio_date ON core.position(portfolio_code, position_date, position_id);
CREATE INDEX idx_position_explorer_instrument_date ON core.position(instrument_id, position_date, position_id);