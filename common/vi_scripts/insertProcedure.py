# spreadsheet is delicate won't touch for now
# 3 files need to be updated to insert a procedure.
# 1. fiji_perf_pktgen.py
# 2. pktgen_fiji.py
# 3. test_fiji.py
# Marker method
# Fields that need to be entered
# ONLY RUN ONCE
name= 'acl3proc_getacl_pkt'
regex = True

markerkey='21efejlru91204jj'
container= name.split('_',1)[0]
lengthcontainer= len(container)
print container

params=open('params.txt')
Fields=['Control']
for line in params:
	if '=' not in line:
		continue
	line = line.split('=',1)[0]
	Fields.append(line.replace(" ",''))


FieldsString='['
g=len(Fields)
for c,i in enumerate(Fields):
	FieldsString+='\''+i+'\''
	if c == g-1:
		break
	FieldsString+=', '
FieldsString+=']'

Fields.pop(0)

#NOTE THAT MAX LENGTH of variable is 30, if you want minimum space of 20
inserted = ""
for c,i in enumerate(Fields):
	temp=""
	if c==0:
		temp+="             "
	else:
		temp+="                   "
	spacesadded = 50-len(i)
	temp+="{0}".format(i)
	temp+=' '*spacesadded
	temp+="=pktcontrol[controlname.index('{0}')],\n".format(i)
	inserted+=temp



line1='from {0}gen import *\n'.format(name)
line2='{0}{1}=0,\n'.format(name," "*(24-len(name))) #name has to be shorter than 24 characters
line3='  {0}{2}= {1}\n'.format(name,FieldsString," "*(25-len(name)))
line4='{0}{1}=0,\n'.format(name," "*(24-len(name))) #name has to be shorter than 24 characters
if regex==False:
	line5=""
else:
	line5='''    elif pktname.startswith('{0}'):
      type="{0}%sgen"%re.split('([0-9]+)', pktname[{1}:])[0]\n'''.format(container,lengthcontainer)
line6='''    elif type == '{0}gen':
      globalpktcount['{0}']+=1
      self.localpktcount['{0}']+=1
      obj = {0}gen(
      {1}
      )
      '''.format(name,inserted)
line7='{0}{1}={0}gen(),\n'.format(name," "*(24-len(name)))

phrases1=[line1,line2,line3,line4,line5,line6]
phrases2=[line1,line7,line2,line2,line5,line5,line6]
phrases3=[line1,line7,line2,line2,line5,line5,line6]
phrases=[phrases1,phrases2,phrases3]

filesToEdit=['fiji_perf_pktgen.py','test_fiji.py','pktgen_fiji.py']

for p,file in enumerate(filesToEdit):
	fileEdited=file
	parse=open(fileEdited)

	indices = []
	for index, line in enumerate(parse):
		if '#21efejlru91204jj' in line:
			indices.append(index)

	offset=0

	for i in range(len(phrases[p])):
		with open(fileEdited, 'r') as file:
			data = file.readlines()
		inserted = phrases[p][i]
		print "insertion made at line: ",
		print indices[i]+offset
		data[indices[i]+offset:indices[i]+offset]=inserted
		offset+=len(inserted.split('\n'))-1
		with open(fileEdited, 'w') as file:
			file.writelines(data)

	print "Done editing {0}.".format(file)

print ("done")





