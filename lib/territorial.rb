require 'territorial/version'
require 'set'

# Expand regional territory shorthand codes to ISO 3166-1 alpha-2 codes and
# parse lists of string codes like <tt>"EU -FR"</tt>
class Territorial
  # The default region expansions. EL and UK are European Union variants of the
  # ISO codes GR and GB respectively.
  EXPANSIONS = {
    'GSA' => %w{DE CH AT},
    'EU' => %w{
      BE BG CZ DK DE EE IE GR ES FR HR IT CY LV LT LU HU MT NL AT PL PT RO SI
      SK FI SE GB
    },
    'EFTA' => %w{CH NO LI IS},
    'WW' => %w{
      AF AX AL DZ AS AD AO AI AQ AG AR AM AW AU AT AZ BS BH BD BB BY BE BZ BJ
      BM BT BO BQ BA BW BV BR IO BN BG BF BI KH CM CA CV KY CF TD CL CN CX CC
      CO KM CG CD CK CR CI HR CU CW CY CZ DK DJ DM DO EC EG SV GQ ER EE ET FK
      FO FJ FI FR GF PF TF GA GM GE DE GH GI GR GL GD GP GU GT GG GN GW GY HT
      HM VA HN HK HU IS IN ID IR IQ IE IM IL IT JM JP JE JO KZ KE KI KP KR KW
      KG LA LV LB LS LR LY LI LT LU MO MK MG MW MY MV ML MT MH MQ MR MU YT MX
      FM MD MC MN ME MS MA MZ MM NA NR NP NL NC NZ NI NE NG NU NF MP NO OM PK
      PW PS PA PG PY PE PH PN PL PT PR QA RE RO RU RW BL SH KN LC MF PM VC WS
      SM ST SA SN RS SC SL SG SX SK SI SB SO ZA GS SS ES LK SD SR SJ SZ SE CH
      SY TW TJ TZ TH TL TG TK TO TT TN TR TM TC TV UG UA AE GB US UM UY UZ VU
      VE VN VG VI WF EH YE ZM ZW
    },
    'EL' => %w{GR},
    'UK' => %w{GB}
  }

  # expand regions from shorthand codes to arrays of ISO codes
  # @return [<String>] the expanded ISO codes
  def self.expand(*regions)
    new.expand(*regions)
  end

  # @param extra_expansions [Hash] optional Hash of additional expansions
  def initialize(extra_expansions = {}, bounds = [])
    @extra_expansions = Hash[extra_expansions.map { |key, values|
      [normalize_territory(key), normalize_territories(values)]
    }]
    if bounds.empty?
      @bounds = nil
    else
      @bounds = expanded_set(normalize_territories(bounds))
    end
  end

  # expand regions from shorthand codes to arrays of ISO codes
  # @return [<String>] the expanded ISO codes
  def expand(*regions)
    regions = normalize_territories(regions.flatten)
    expanded_set(regions).to_a
  end

  # Parse strings like 'EU -GB' or 'EU +RU' to fully expanded arrays of ISO
  # codes. Expandable codes (i.e. EU) will be expanded, codes with a `-` prefix
  # will be removed from the result and codes with a `+` prefix, or with no
  # prefix will be added to the result. 
  # @param territory_list [String] the list of territories (and modifiers) as a string
  # @return [<String>] the expanded ISO codes
  def territories(territory_list)
    parser = Parser.new(territory_list)
    allowed = expanded_set(parser.accept)
    rejected = expanded_set(parser.reject)
    (allowed - rejected).to_a
  end

  private

  def normalize_territory(territory_string)
    territory_string.to_s.upcase
  end

  def normalize_territories(territory_strings)
    territory_strings.map { |ts| normalize_territory(ts) }
  end

  def expansions
    @expansions ||= EXPANSIONS.merge(@extra_expansions)
  end

  def expansion_regions
    expansions.keys
  end

  def expandable?(region)
    expansions.has_key?(region.to_s)
  end

  def constrained(territories)
    return territories if @bounds.nil?
    territories & @bounds
  end

  def expanded_set(regions)
    territories = Set.new
    already_expanded = Set.new

    expand_set(territories, regions, already_expanded)
    constrained(territories)
  end

  def expand_set(territories, regions, already_expanded)
    regions.inject(territories) do |territories, region|
      if expandable?(region) && !already_expanded.include?(region)
        territories.merge(expand_set(territories, expansions[region], already_expanded << region))
      else
        territories << region
      end
    end
  end

  class Parser
    TOKEN = /([+-]?)([a-z]+)(?:\s|$)/i
    attr_reader :input

    def initialize(input)
      @input = input
    end

    def tokens
      @tokens ||= input.scan(TOKEN)
    end

    def accept
      @accept ||= tokens.reject { |prefix, code|
        prefix == '-'
      }.map { |prefix, code|
        code
      }
    end

    def reject
      @reject ||= tokens.select { |prefix, code|
        prefix == '-'
      }.map { |prefix, code|
        code
      }
    end
  end
end
