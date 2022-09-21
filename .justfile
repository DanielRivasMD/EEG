####################################################################################################

_default:
  @just --list

####################################################################################################

# print justfile
@show:
  bat .justfile --language make

####################################################################################################

# edit justfile
@edit:
  micro .justfile

####################################################################################################

# aliases

####################################################################################################

# julia project
@proj:
  julia --project

####################################################################################################

# julia development
@dev:
  julia -i --project --startup no --eval 'include("/Users/drivas/.archive/cerberus/julia/development.jl")'

####################################################################################################

####################################################################################################
# local analysis
####################################################################################################

# Vesta is the virgin goddess of the hearth, home, and family in Roman religion.
# She was rarely depicted in human form, and was more often represented by the fire of her temple in the Forum Romanum.
# Entry to her temple was permitted only to her priestesses, the Vestal Virgins, who guarded particular sacred objects within, prepared flour and sacred salt (mola salsa) for official sacrifices, and tended Vesta's sacred fire at the temple hearth.
# Their virginity was thought essential to Rome's survival; if found guilty of inchastity, they were punished by burial alive.
# As Vesta was considered a guardian of the Roman people, her festival, the Vestalia (7–15 June), was regarded as one of the most important Roman holidays.
# During the Vestalia privileged matrons walked barefoot through the city to the temple, where they presented food-offerings.
# Such was Vesta's importance to Roman religion that following the rise of Christianity, hers was one of the last non-Christian cults still active, until it was forcibly disbanded by the Christian emperor Theodosius I in AD 391.

# The myths depicting Vesta and her priestesses were few; the most notable of them were tales of miraculous impregnation of a virgin priestess by a phallus appearing in the flames of the sacred hearth — the manifestation of the goddess combined with a male supernatural being.
# In some Roman traditions, Rome's founders Romulus and Remus and the benevolent king Servius Tullius were conceived in this way.
# Vesta was among the Dii Consentes, twelve of the most honored gods in the Roman pantheon.
# She was the daughter of Saturn and Ops, and sister of Jupiter, Neptune, Pluto, Juno, and Ceres.
# Her Greek equivalent is Hestia.

####################################################################################################

# collect time stampts
@Vesta-performance:
  source src/bin/shell/performanceConcatenate.sh

####################################################################################################
