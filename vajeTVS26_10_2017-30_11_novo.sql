use AdventureWorks2014

select sd.ProductID, count(distinct sd.ProductID) 
from Sales.SalesOrderDetail sd
group by sd.ProductID

select sd.customerid, count(distinct sd.TerritoryID) as tid
from Sales.SalesOrderHeader sd
group by sd.CustomerID

select p.FirstName,p.LastName, COUNT(*)
from Person.Person as p
inner join Sales.Customer as c on p.BusinessEntityID = c.CustomerID
inner join Sales.SalesOrderHeader as soh on c.CustomerID = soh.CustomerID
group by p.FirstName,p.LastName

select max(p.name),p.productid, soh.OrderDate,SUM(sod.OrderQty)
from Sales.SalesOrderHeader as soh
inner join Sales.SalesOrderDetail as sod on soh.SalesOrderID = sod.SalesOrderID
inner join  Production.Product as p on sod.ProductID = p.ProductID
group by p.ProductID,soh.OrderDate
order by p.ProductID,soh.OrderDate

/*se maximalno vrednost narocila-vrednosti narocila*/

select table1.*, h.OrderDate
from
(SELECT CustomerID,
	(SELECT COUNT(*)
	FROM Sales.SalesOrderHeader	soh
	WHERE soh.CustomerID = C.CustomerID) AS CountOfSales,
	(select max(soh.subtotal)
	from Sales.SalesOrderHeader soh
	where soh.CustomerID = c.CustomerID) as maxsale
FROM Sales.Customer AS C  ) as table1
/*ORDER BY CountOfSales DESC;*/
join Sales.SalesOrderHeader as h on h.CustomerID = table1.CustomerID

/* order by v derived tabeli negre*/

select soh.CustomerID,soh.SubTotal, avg(SubTotal) as povp
from Sales.SalesOrderHeader soh

select soh.CustomerID, soh.SubTotal, AVG(soh.SubTotal) over() as povp,
									 STDEV(soh.SubTotal) over() as stdev,
									 MIN(soh.SubTotal) over() as minval
from Sales.SalesOrderHeader soh

/* normalizirtat pa standarizirat subtotal ko uceri(25.10.2017) */

/*za usak job title povedat kolko emplojijev majo*/
select p.FirstName,e.HireDate, e.JobTitle, (select count(*)
											from HumanResources.Employee as h
											where h.JobTitle = e.JobTitle) as numOfEmplyees
from HumanResources.Employee as e
join Person.Person as p on e.BusinessEntityID = p.BusinessEntityID

select p.FirstName,e.HireDate, e.JobTitle
from HumanResources.Employee as e
join Person.Person as p on p.BusinessEntityID = e.BusinessEntityID
join
	(select h.JobTitle, count(*) as number					
	from HumanResources.Employee as h
	group by h.JobTitle) as jobNum on e.JobTitle = jobNum.JobTitle


with neki as (select e.JobTitle, COUNT(*) as number
			from HumanResources.Employee e
			group by e.JobTitle)
select p.FirstName,h.JobTitle,h.HireDate,neki.number
from HumanResources.Employee as h
join Person.Person as p on p.BusinessEntityID = h.BusinessEntityID
join neki on neki.JobTitle = h.JobTitle


select p.FirstName,e.JobTitle,e.HireDate,COUNT(*) over() as overResitev
from HumanResources.Employee as e
join Person.Person as p on p.BusinessEntityID = e.BusinessEntityID


with neki2 as (select soh2.CustomerID
				from Sales.SalesOrderHeader as soh2
				/*en customer ma vec orderjev*/
				group by soh2.CustomerID
				having COUNT(* /*soh2.customerid*/) > 4)

select soh.CustomerID,soh.SalesOrderID,soh.OrderDate
from Sales.SalesOrderHeader as soh
inner join neki2 on neki2.CustomerID = soh.CustomerID



select *
from (select count(*) over(partition by soh.customerid) as overResitev,soh.CustomerID,soh.SalesOrderID,soh.OrderDate
	  from Sales.SalesOrderHeader as soh) as neki
where neki.overResitev > 4


/* dajamo pravice na shemo */

create schema tmp;
go
/*ni delalo*/


/*manipulating data*/
select *
from Production.Product

insert into dbo.demoproduct ([ProductID],[Name],[Color],[StandardCost],[ListPrice])
values (333,'Ljubo','Blue',1000,2000)

insert into dbo.demoproduct ([ProductID],[Name],[Color],[StandardCost],[ListPrice],[Size],[Weight])
values (3333,'Ljubo','Blue',1000,2000,33,33.33),(33,'Ljubo','Blue',1000,2000,null,null),(3,'Ljubo','Blue',1000,2000,null,null)


select distinct(select count(*)
			from tmp.Import tmp2
			where tmp2.gender = 'Male') as moski, (select count(*)
			from tmp.Import tmp3
			where tmp3.gender = 'Female') as zenske
from tmp.Import as tmp


select *
from tmp.Import tmp


select COUNT(case when tmp.Import.gender='Male' then 1 end) as moski, COUNT(case when tmp.Import.gender = 'Female' then 1 end) as zenske
from tmp.Import

/*salesId pustimo prazen ker mamo identity, date isto zaradi getdate in je nullprivzeto */

insert into dbo.demosalesorderheader ([SalesOrderID],[OrderDate],[CustomerID],[SubTotal],[TaxAmt],[Freight],
	[SalesNumber])
select soh.SalesOrderID,soh.OrderDate,soh.CustomerID,soh.SubTotal,soh.TaxAmt,soh.Freight,
	soh.SalesOrderID 
from Sales.SalesOrderHeader as soh



/*4.exercise*/
select sc.CustomerID, COUNT(sc.CustomerID) as neki, SUM(soh.TotalDue) as neki2
into dbo.tempcustomersales2
from Sales.Customer as sc
join Sales.SalesOrderHeader as soh on soh.CustomerID = sc.CustomerID
group by sc.CustomerID


/*5.exercise*/
insert into dbo.demoproduct ([ProductID],[Name],[Color],[StandardCost],[ListPrice],[Size],[Weight])
select p.ProductID,p.name,p.Color,p.StandardCost,p.ListPrice,p.Size,p.weight
from Production.Product as p
join dbo.demoproduct as dp on dp.ProductID = p.ProductID
where dp.ProductID is null

/*3.11.2017 deleting*/

with neki4 as(
select dc.customerid
from dbo.democustomer as dc
left outer join dbo.demoSalesOrderHeader as dsoh on dsoh.CustomerID=dc.customerid
group by dc.customerid
having SUM(ISNULL(dsoh.TotalDue,0)) < 1000)

delete blabla
from dbo.democustomer as blabla
inner join neki4 as dsoh on dsoh.CustomerID = blabla.customerid;

/*customer ki nima nic not ki ni plejsau orderja
	delete c
	from dbo.democustomer
	dbo.demosalesorderhearder as h
	where h.customerid is null*/

/*njegova resitev*/
delete c
	from dbo.democustomer as c
	left join dbo.demosalesorderheader as h on c.customerid = h.customerid
	where h.customerid is null or h.customerid in
(select customerid
from demoSalesOrderHeader
group by CustomerID
having sum (TotalDue) < 1000)

/*tretje nism ma je u resitvah je logicna*/

update dbo.demoAddress /*ne moremo met as-a*/
set AddressLine2 = 'N/A'
where a.AddressLine2 is null

update dbo.demoProduct
set ListPrice = ListPrice*1.1;

update dsod
set unitprice = listprice
from dbo.demoSalesOrderDetail as dsod
join dbo.demoProduct as dp on dp.ProductID = dsod.productid;

update dsoh
set dsoh.subtotal = sum(dsod.linetotal)
from dbo.demoSalesOrderHeader as dsoh
join dbo.demoSalesOrderDetail as dsod on dsod.salesorderid = dsoh.SalesOrderID
/*nemors met agregacije u set-u*/

update d
set SubTotal = neki
from dbo.demoSalesOrderHeader as d
join neki2 on neki.salesorderid = d.SalesOrderID

with neki2 as (
	select SUM(dd.linetotal) as neki,dd.salesorderid
	from dbo.demoSalesOrderDetail as dd
	group by dd.salesorderid
)
update d
set SubTotal = neki
from dbo.demoSalesOrderHeader as d
join neki2 on neki2.SalesOrderID = d.SalesOrderID;




/* transakcija */
if object_id('dbo.demo') is not null begin
	drop table dbo.demo;
	end;
	go
	create table dbo.demo(id int primary key,name varchar(25));

begin tran
	insert into dbo.demo (id,name)
	values (33,'mojmir')
commit tran

select id,name
from dbo.demo

declare @minid int, @maxid int
select @minid=MIN(soh.salesorderid), @maxid = max(soh.salesorderid)
from sales.SalesOrderHeader as soh

print @maxid
print @minid

declare @id int = 70000;
select soh.SalesOrderID
from Sales.SalesOrderHeader as soh
where soh.SalesOrderID > @id


declare @a int
select @a = count(soh.CustomerID)
from Sales.SalesOrderHeader as soh

print @a

select @a,@a - count(soh2.CustomerID)
from Sales.SalesOrderHeader as soh2
group by soh2.CustomerID

print @a

/* mankau dve vaji */

/* 15.11.2017 */
/* iz une datoteke vaje delam */
use AdventureWorks2014

select*
from dbo.import as di

/*1,2*/
select AVG(di.sales) as avgSale, (select avg(dii.sales)
									from dbo.import as dii
									where dii.country='Slovenia') as avgS
from dbo.import as di

/*3*/
select dii.date,
(select COUNT(di.sales) as numSales
from dbo.import as di
where di.seller = 'Tina' and di.date>'2013-12-31' and di.date<'2015-1-1'
)
from dbo.import as dii


select dii.date,
(select COUNT(di.sales) as numSales
from dbo.import as di
where di.seller = 'Tina' and year(di.date)=2014
)
from dbo.import as dii
/*da vgnezden je ok*/


select top (1) di.date, DATEDIFF(day,di.date,getdate()) as numDays
from dbo.import as di
order by di.date desc

select*
from dbo.import as di


select SUM(di.sales)
from dbo.import as di
where di.seller='ronald' and di.country='france' and YEAR(di.date)=2014 and di.item='tablet'

select top(1) di.seller
from dbo.import as di
where YEAR(di.date)=2015 and di.item='pc'
group by di.seller
order by (sum(di.sales)) asc

select top(1) di.seller
from dbo.import as di
where YEAR(di.date)=2015 and di.item='pc'
order by di.sales asc

/*TO NI PRAU*/
select di.country,(( count(di.sales) / (select count(diii.sales)from dbo.import as diii) )*100)
from dbo.import as di
where di.country='slovenia'
group by di.country


declare @total float
select @total = COUNT(di.sales) from dbo.import as di
select (COUNT(dii.sales) / @total )*100
from dbo.import as dii
where dii.country='slovenia'

declare @total float 
select @total = COUNT(di.sales) from dbo.import as di
DECLARE @slo FLOAT = (select count(dii.sales) from dbo.import as dii where dii.country='slovenia')

select (@slo/@total)*100



/* while zanke */

/* 65 je a */
declare @letter char(1)
set @letter = CHAR (65)
print @letter

/* z je 90*/
declare @letterZ char(1) = char(90)
print @letterZ

declare @stevec int = 65
while @stevec < 91 begin
	print char(@stevec)
	set @stevec = @stevec+1
end;

declare @produkt int =1;
declare @stevec int = 1;
declare @stevec2 int = 1;

while @stevec <= 100 begin
	set @stevec2 = 1
	while @stevec2 <= 5 begin
		set @produkt = @stevec * @stevec2
		print @produkt
		set @stevec2 += 1
	end
	set @stevec = @stevec+1
end


/* 3naloga */

declare @produkt int =1;
declare @stevec int = 1;
declare @stevec2 int = 1;

while @stevec <= 100 begin
	set @stevec2 = 1
	while @stevec2 <= 5 begin
		if @stevec % 5 = 0 begin
		print 'erorr'
			break
		end
		set @produkt = @stevec * @stevec2
		print @produkt
		set @stevec2 += 1
	end
	set @stevec = @stevec+1
end


/* 4naloga */

declare @stevec int = 1
while @stevec <= 100 begin
	if @stevec % 2 = 0 begin
		print 'even'
	end
	else begin
		print 'odd'
	end
	set @stevec += 1
end;


/* vsako 3 narocilo prodajalca na crko 'a' --> sales order header */
select soh.SalesOrderID, pp.FirstName
from Sales.SalesOrderHeader as soh
join Person.Person as pp on pp.BusinessEntityID = soh.salespersonid
where pp.FirstName like 'a%' and 
order by soh.SalesOrderID


/* NE DELA */
select soh.SalesOrderID, pp.FirstName, (ROW_NUMBER() over (order by soh.salesorderid)) % 3 = 0 
from Sales.SalesOrderHeader as soh
join Person.Person as pp on pp.BusinessEntityID = soh.salespersonid
where pp.FirstName like 'a%' 

/* DELA */
drop table if exists #tmporders
select s.*, row_number() over (order by s.salesorderid) as rownum into #tmporders
from sales.salesorderheader as s
join person.person as p on p.BusinessEntityID = s.salespersonid
where p.firstname like 'a%'

select *
from #tmporders
where rownum % 3 = 0



select s.*, row_number() over (order by s.salesorderid) as rownum
into #tmporders
from sales.salesorderheader as s
join person.person as p on p.BusinessEntityID = s.salespersonid
where p.firstname like 'a%'

declare @max int
declare @i int
set @i = 1

while @i <= 39 begin
	if @i % 3 = 0 begin
		select *
		from #tmporders
		where rownum = @i
	end
	set @i = @i+1
end


drop table if exists #tmporders

declare @max int
declare @letter nchar(2)
set @letter = 'a'

select s.*, row_number() over (order by s.salesorderid) as rownum
into #tmporders
from sales.salesorderheader as s
join person.person as p on p.BusinessEntityID = s.salespersonid
where LEFT(p.FirstName,1) = @letter

set @max = @@ROWCOUNT

declare @i int
set @i = 1

while @i <= @max begin
	if @i % 3 = 0 begin
		select *
		from #tmporders
		where rownum = @i
	end
	set @i = @i+1
end


/* povp starost narocila-orderdate v mesecih na danasnji dan --->salesorderheader  50result*/
select soh.OrderDate,AVG(cast(soh.OrderDate as int)) as bla
from Sales.SalesOrderHeader as soh
where DAY(soh.OrderDate) = 15
group by soh.OrderDate


/*avg od razlikeé(inline)*/


/* naloge vaje za kolokvij */

/* HOW TO RESTORE A DATABASE KOLOKVIJ!!!*/

/* 1 identifiy the sales across the stores and years
2 which store was the most lucrative over the years
3 define the sales across region
4 show the indexes of sales across product category
also with charts*/

/*1 kasna je bla prodaja po trgovinah po letih? indentify=sum*/

select *
from Sales.SalesOrderHeader as soh

/*diagram databasediagram*/
use AdventureWorks2014
sp_changeDbowner 'sa'
go
/*new diagram, add related  tables, arrange tables*/

select YEAR(soh.OrderDate)as leto, sc.StoreID as storeId, max(ss.Name) as nejm, SUM(soh.TotalDue) as cena
from Sales.Customer as sc
join Sales.SalesOrderHeader as soh on sc.CustomerID = soh.CustomerID 
join Sales.Store as ss on ss.BusinessEntityID = sc.StoreID
group by sc.StoreID, year(soh.OrderDate)



/*2 uzames povp.prodajo ene trgovine po letin in izracunas procent kera je najbolsa*/

select YEAR(soh.OrderDate)as leto, sc.StoreID as storeId, max(ss.Name) as nejm, SUM(soh.TotalDue) as cena
into #tmp33
from Sales.Customer as sc
join Sales.SalesOrderHeader as soh on sc.CustomerID = soh.CustomerID 
join Sales.Store as ss on ss.BusinessEntityID = sc.StoreID
group by sc.StoreID, year(soh.OrderDate)

select distinct *
into #tmp333
from #tmp33
order by #tmp33.leto,name

select top (1) avg(#tmp33.cena)
from Sales.SalesOrderHeader as soh2,#tmp33
group by #tmp33.cena
order by #tmp33.cena
/* NE DELA JEBIGA*/

select sum(SubTotal) over(partition by (year(OrderDate))) as Sale, YEAR(OrderDate) as YearS, st.Name
into #zac
from Sales.Store as st
inner join Sales.SalesOrderHeader as soh
on st.SalesPersonID = soh.SalesPersonID
go

select distinct *
into #zac2
from #zac
order by Name, YearS

select  Top(1) avg(sale) as TSale, Name
from #zac2
group by Name
order by  TSale

/*3 define the sales across region*/

select SUM(soh.TotalDue)as cena, max(st.CountryRegionCode) as regija,st.TerritoryID,max(st.Name) as terotorija
from Sales.Customer as sc
join Sales.SalesTerritory as st on st.TerritoryID=sc.TerritoryID
join Sales.SalesOrderHeader as soh on soh.CustomerID = sc.CustomerID
group by st.TerritoryID

/*4*/


/*5 Najboljöi kupec po izdelku po letih */

select top(1) max(pp.FirstName) as imeKupca, YEAR(soh.OrderDate) as leto,SUM(soh.TotalDue) as cena
from Sales.Customer as sc
join Person.Person as pp on sc.CustomerID = pp.BusinessEntityID
join Sales.SalesOrderHeader as soh on soh.CustomerID = sc.CustomerID
group by YEAR(soh.OrderDate) 
order by cena desc

/*618 vrstic*/



/* 30.11.2017  vaje */

/* writing advanced querries */
/* exercise 1*/
/*1. */
use DoctorWho
select e.EpisodeId
from dbo.tblEpisode as e
join dbo.tblAuthor as a on e.AuthorId = a.AuthorId
where a.AuthorName like 'mp%' or a.AuthorName like '%mp%' or a.AuthorName like 'mp%'

/*2.*/
with neki as(
select e.EpisodeId
from dbo.tblEpisode as e
join dbo.tblAuthor as a on e.AuthorId = a.AuthorId
where a.AuthorName like 'mp%' or a.AuthorName like '%mp%' or a.AuthorName like 'mp%'
)

select c.CompanionName
from neki as n
join tblEpisodeCompanion as ec on n.EpisodeId = ec.EpisodeId
join tblCompanion as c on c.CompanionId = ec.CompanionId

/*3. */
/* episodes featuring rose but not tennant*/
/* rose je companion, david je enemy*/
with bla as(
select e.EpisodeId,c.CompanionName,e.Title
from tblEpisode as e
join tblEpisodeCompanion as ec on e.EpisodeId = ec.EpisodeId
join tblCompanion as c on c.CompanionId = ec.CompanionId
where c.CompanionName = 'Rose Tyler'
),
bla2 as(
select d.DoctorName,e.EpisodeId
from tblEpisode as e
join tblDoctor as d on e.DoctorId = d.DoctorId
where d.DoctorName != 'David Tennant'
)
select distinct EnemyName
from bla as b
join bla2 as b2 on b.episodeid = b2.episodeid
join tblEpisodeEnemy as ee on ee.EpisodeId = b.EpisodeId
join tblEnemy as te on te.EnemyId = ee.EnemyId



/* 4. */
with neki as(
select distinct e.title,d.doctorname,e.EpisodeId,tenemy.EnemyName
from tblEpisode as e 
join tblDoctor as d on d.DoctorId = e.DoctorId
join tblEpisodeEnemy as tee on tee.EpisodeId = e.EpisodeId
join tblEnemy as tenemy on tenemy.EnemyId = tee.EnemyId
where d.DoctorName = 'David Tennant'
),
/* enemiji ki so tu se ne smejo pojavit zgoraj */
neki2 as (
select distinct te.Title,tenemy.EnemyName, te.EpisodeId
from tblEpisode as te
join tblDoctor as td on td.DoctorId = te.DoctorId
join tblEpisodeEnemy as tee on tee.EpisodeId = te.EpisodeId
join tblEnemy as tenemy on tenemy.EnemyId = tee.EnemyId
where td.DoctorName != 'David Tennant'
)
select distinct n.Title
from neki as n
where n.EnemyName not in (
	select n2.enemyname
	from neki2 as n2
	)


/*32 je resitev: */
with ep as (
	select e.title,d.DoctorName,enemyname
	from dbo.tblEpisode as e
	join dbo.tblDoctor as d on e.DoctorId = d.DoctorId
	join dbo.tblEpisodeEnemy as en on en.EpisodeId = e.EpisodeId
	join dbo.tblEnemy as enem on enem.EnemyId = en.EnemyId
)
select distinct title
from ep 
where doctorname='David Tennant'
and enemyname not in (
	select enemyname
	from ep
	where Doctorname != 'David Tennant'
	)
order by title /* cisto za öminko */


/* 5. */
use carnival
select t.MenuId,t.ParentMenuId
from dbo.tblMenu as t

with neki (menuid,ParentMenuId,menuname,level) as 
	(
	select t.MenuId,t.ParentMenuId,t.menuname, 0 as level
	from dbo.tblMenu as t
	where t.ParentMenuId is null
	union all

select t2.menuid,t2.ParentMenuId,t2.menuname,tt.level + 1
from dbo.tblMenu as t2
join neki as tt on t2.ParentMenuId = tt.menuId
)
select y.menuid,y.parentmenuid,y.menuname,y.level
from neki as y /* lahko tui brez y-ona */



/* vaje 7.12.2017 */
use AdventureWorks2014
/* 1. */
declare @mytablevar table (
	newscrapreasonid smallint,
	name varchar(50),
	modifieddate datetime
)
/*
select *
from @mytablevar
*/
/* prvi stolpec je identity avtomatsko ga ni treba zajet noter */


insert into Production.scrapreason (Name,ModifiedDate)
OUTPUT inserted.ScrapReasonID, inserted.Name,inserted.ModifiedDate
into @mytablevar
values ('operator error', GETDATE())

select *
from Production.ScrapReason

/*SMO DODALI samo eno vrstico */


/* 2. */
delete from Sales.ShoppingCartItem
output DELETED.*
where ShoppingCartID = 20621


select *
from Sales.ShoppingCartItem



/* 3. */
declare @mytablevar table(
	empid int not null,
	oldvacationhours int,
	newvacationhours int,
	modifieddate datetime
)

update top (10) HumanResources.Employee
set vacationhours = vacationhours + (vacationhours * 0.25)
output inserted.businessentityid, deleted.vacationhours, inserted.vacationhours ,getdate()
into @mytablevar

select *
from @mytablevar

select*
from HumanResources.Employee


/* exercise */
use adventureworks2014
/* 1. */

merge dbo.department_target as dt
using dbo.Department_Source as ds
on dt.departmentid = ds.departmentid
when not matched by target then
insert (departmentid,name,groupname,modifieddate) values (departmentid,name,groupname,modifieddate)
output $action,inserted.*;

/* 2. */
update dbo.department_source
	set groupname='IT'

merge dbo.department_target as dt
using dbo.Department_Source as ds
on dt.departmentid = ds.departmentid
when matched then
update set dt.groupname=ds.groupname
output $action,deleted.*,inserted.*;


/* 3. in 4. */
insert into dbo.department_target
	values (3,'sales','sales&marketing',getdate())

merge dbo.department_target as dt
using dbo.Department_Source as ds
on dt.departmentid = ds.departmentid
when not matched by source then
delete
output $action,deleted.*,inserted.*;

select *
from dbo.department_source
select *
from dbo.department_target


/* 5. pejdi na mergeexercise od 50line naprej, dropni create tabele in izvedi spodnje inserte*/

merge dbo.Department_Target as dt
using dbo.Department_Source as ds
on dt.departmentid = ds.departmentid
when not matched by target then
insert (departmentid,name,groupname,modifieddate) values (departmentid,name,groupname,modifieddate)
when matched then
update set dt.name = ds.name
when not matched by source then
delete
output $action,deleted.*,inserted.*;


/* pivot */
/* total salary by department */

/* 1. use case pivot */

select *
from employees
select *
from departments

select SUM(case when d.dept_name='Sales' then salary else 0 end) as sales,
	   SUM(case when d.dept_name='Accounting' then salary else 0 end ) as acounting
from employees as e
join departments as d on e.dept_id = d.dept_id

/* brez group by salarys */


/* 2. */
select neki.[30] as asccount,neki.[45] as sales
from (
	select dept_id,salary
	from employees) as tmpSalary
pivot (
	sum(salary)
	for dept_id in ([45],[30])
) as neki























































































































































